/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.ArrangerWorkstation {
    public class Console {
        public static bool verbose = true;
        public static string domain = "";

        private const string RED = "\x1B[31m";
        private const string GRN = "\x1B[32m";
        private const string YEL = "\x1B[33m";
        private const string BLU = "\x1B[34m";
        private const string MAG = "\x1B[35m";
        private const string CYN = "\x1B[36m";
        private const string WHT = "\x1B[37m";
        private const string BOLD = "\x1B[1m";
        private const string RESET = "\x1B[0m";

        public static void get_console_header (string app_version, string display_version) {
            print (MAG);
            print ("███████ ███    ██ ███████ ███████ ███    ███ ██████  ██      ███████ ███████\n");
            print ("██      ████   ██ ██      ██      ████  ████ ██   ██ ██      ██      ██\n");
            print ("█████   ██ ██  ██ ███████ █████   ██ ████ ██ ██████  ██      █████   ███████\n");
            print ("██      ██  ██ ██      ██ ██      ██  ██  ██ ██   ██ ██      ██           ██\n");
            print ("███████ ██   ████ ███████ ███████ ██      ██ ██████  ███████ ███████ ███████\n");
            print (RED);
            print ("============================================================================\n");
            print (YEL);
            print (_("VERSION: %s, DISPLAY VERSION: %s   |   (c) SUBHADEEP JASU 2020 - 2023\n"),
             app_version, display_version);
            print (RED);
            print ("----------------------------------------------------------------------------\n");
            print (RESET);
        }

        public enum LogLevel {
            SUCCESS,
            TRACE,
            WARNING,
            ERROR,
        }

        public static void log <T> (T object, LogLevel log_level = LogLevel.TRACE) {
            DateTime date_time = new DateTime.now_utc ();
            string message = "";
            if (typeof (T) == Type.STRING) {
                message = (string) object;
            } else if (typeof (T) == typeof (Error)) {
                message = ((Error) object).domain.to_string ()
                .replace ("-quark", "")
                .replace ("-", " ")
                .up ();
                message += ": " + ((Error) object).message;
            }

            switch (log_level) {
                case SUCCESS:
                if (verbose) {
                    print ("%s▎%s%sSUCCESS %s[%s%s%s]: %s\n", GRN, WHT, BOLD,
                        RESET, BLU, date_time.to_string (), RESET, message);
                }
                break;
                case TRACE:
                if (verbose) {
                    print ("%s▎%s%sTRACE   %s[%s%s%s]: %s\n", CYN, WHT, BOLD, RESET, BLU, date_time.to_string (),
                        RESET, message);
                }
                break;
                case WARNING:
                if (verbose) {
                    print ("%s▎%s%sWARNING %s[%s%s%s]: %s%s%s\n", YEL, WHT, BOLD, RESET, BLU, date_time.to_string (),
                        RESET, YEL, message, RESET);
                }
                break;
                case ERROR:
                if (verbose) {
                    print ("%s▎%s%sERROR %s[%s%s%s]: %s%s%s\n", RED, WHT, BOLD, RESET, BLU, date_time.to_string (),
                        RESET, RED, message, RESET);
                }
                GLib.log (domain, LogLevelFlags.LEVEL_ERROR, message);
                break;
            }
        }
    }
}
