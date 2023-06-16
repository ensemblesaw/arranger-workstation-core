/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Ensembles.ArrangerWorkstation.Utils {
    public class Math {
        /**
         * Returns a value mapped from one range into another.
         *
         * @param value the value in input range
         * @param in_range_min input range min
         * @param in_range_max input range max
         * @param out_range_min output range min
         * @param out_range_max output range max
         * @return mapped value in output range
         */
        public static double map_range_unclamped (double value,
            double in_range_min, double in_range_max,
            double out_range_min, double out_range_max) {
            return out_range_min + (
                (out_range_max - out_range_min) / (in_range_max - in_range_min)
            ) * (value - in_range_min);
        }

        /**
         * Returns a value mapped from one range into another.
         *
         * @param value the value in input range
         * @param in_range_min input range min
         * @param in_range_max input range max
         * @param out_range_min output range min
         * @param out_range_max output range max
         * @return mapped value in output range
         */
         public static float map_range_unclampedf (float value,
            float in_range_min, float in_range_max,
            float out_range_min, float out_range_max) {
            return out_range_min + (
                (out_range_max - out_range_min) / (in_range_max - in_range_min)
            ) * (value - in_range_min);
        }

        public static double convert_db_to_gain (double db) {
            return GLib.Math.pow (10, db / 20);
        }

        public static double convert_gain_to_db (double gain) {
            return 20 * GLib.Math.log10 (gain);
        }
    }
}
