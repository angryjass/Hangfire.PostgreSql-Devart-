﻿// This file is part of Hangfire.PostgreSql.
// Copyright © 2014 Frank Hommers <http://hmm.rs/Hangfire.PostgreSql>.
// 
// Hangfire.PostgreSql is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as 
// published by the Free Software Foundation, either version 3 
// of the License, or any later version.
// 
// Hangfire.PostgreSql  is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public 
// License along with Hangfire.PostgreSql. If not, see <http://www.gnu.org/licenses/>.
//
// This work is based on the work of Sergey Odinokov, author of 
// Hangfire. <http://hangfire.io/>
//   
//    Special thanks goes to him.

using System;
using System.Data;
using System.Globalization;
using System.IO;
using System.Reflection;
using Hangfire.Logging;
using System.Resources;
using Devart.Data.PostgreSql;

namespace Hangfire.PostgreSql
{
    public static class PostgreSqlObjectsInstaller
    {
        private static readonly ILog Log = LogProvider.GetLogger(typeof(PostgreSqlStorage));

        public static void Install(PgSqlConnection connection, string schemaName = "hangfire")
        {
            if (connection == null)
                throw new ArgumentNullException(nameof(connection));

            Log.Info("Start installing Hangfire SQL objects...");

            // starts with version 3 to keep in check with Hangfire SqlServer, but I couldn't keep up with that idea after all;
            int version = 3;
            int previousVersion = 1;
            do
            {
                try
                {
                    string scriptsStr = null;
                    try
                    {
                        scriptsStr = GetStringResource(
                            typeof(PostgreSqlObjectsInstaller).GetTypeInfo().Assembly,
                            $"Hangfire.PostgreSql.Scripts.Install.v{version.ToString(CultureInfo.InvariantCulture)}.sql");
                    }
                    catch (MissingManifestResourceException)
                    {
                        break;
                    }

                    if (schemaName != "hangfire")
                    {
                        scriptsStr = scriptsStr.Replace("'hangfire'", $"'{schemaName}'").Replace(@"""hangfire""", $@"""{schemaName}""");
                    }

                    if (!VersionAlreadyApplied(connection, schemaName, version))
                    {
                        using (var transaction = connection.BeginTransaction(IsolationLevel.Serializable))
                        {
                            var scriptsArr = scriptsStr.Split(new string[] { "--separator" }, StringSplitOptions.None);
                            foreach (var script in scriptsArr)
                            {
#pragma warning disable CA2100 // Review SQL queries for security vulnerabilities
                                using (var command = new PgSqlCommand(script, connection, transaction))
#pragma warning restore CA2100 // Review SQL queries for security vulnerabilities
                                {
                                    command.CommandTimeout = 120;
                                    try
                                    {
                                        command.ExecuteNonQuery();
                                    }
                                    catch (PgSqlException ex)
                                    {
                                        if ((ex.ToString() ?? "") != "version-already-applied")
                                        {
                                            throw;
                                        }
                                    }
                                }
                            }

                            using (var command = new PgSqlCommand($@"; UPDATE ""{schemaName}"".""schema"" SET ""version"" = @version WHERE ""version"" = @previousVersion", connection, transaction))
                            {
                                command.Parameters.AddWithValue("@version", version);
                                command.Parameters.AddWithValue("@previousVersion", previousVersion);

                                command.ExecuteNonQuery();
                            }
                            transaction.Commit();
                        }
                    }
                }
                catch (Exception ex)
                {
                    if (ex.Source.Equals("Npgsql"))
                    {
                        Log.ErrorException("Error while executing install/upgrade", ex);
                    }
                }

                previousVersion = version;
                version++;
            } while (true);

            Log.Info("Hangfire SQL objects installed.");
        }

        private static bool VersionAlreadyApplied(PgSqlConnection connection, string schemaName, int version)
        {
            try
            {
                using (PgSqlCommand command = new PgSqlCommand($@"SELECT true :: boolean ""VersionAlreadyApplied"" FROM ""{schemaName}"".""schema"" WHERE ""version""::integer >= @version", connection))
                {
                    command.Parameters.AddWithValue("@version", version);
                    object result = command.ExecuteScalar();
                    if (true.Equals(result)) return true;
                }
            }
            catch (PgSqlException ex)
            {
                if (ex.ErrorSql == "42P01")    //Relation (table) does not exist. So no schema table yet.
                    return false;

                throw;
            }

            return false;
        }

        private static string GetStringResource(Assembly assembly, string resourceName)
        {
            using (var stream = assembly.GetManifestResourceStream(resourceName))
            {
                if (stream == null)
                    throw new MissingManifestResourceException($"Requested resource `{resourceName}` was not found in the assembly `{assembly}`.");

                using (var reader = new StreamReader(stream))
                {
                    return reader.ReadToEnd();
                }
            }
        }
    }
}