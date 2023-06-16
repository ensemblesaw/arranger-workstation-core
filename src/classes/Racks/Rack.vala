/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.ArrangerWorkstation.Plugins.AudioPlugins;

namespace Ensembles.ArrangerWorkstation.Racks {
    /**
     * Racks can be populated with plugins which are then used to
     * process audio
     */
    public abstract class Rack : Object {
        protected List<AudioPlugin> plugins;

        public bool active = true;

        public AudioPlugin.Category rack_type { get; protected set; }

        // Sound buffers
        float[] aud_buf_dry_l;
        float[] aud_buf_dry_r;
        float[] aud_buf_mix_l;
        float[] aud_buf_mix_r;

        public signal void on_plugin_connect (int change_index);

        construct {
            plugins = new List<AudioPlugin> ();
        }

        public unowned List<AudioPlugin> get_plugins () {
            return plugins;
        }

        /**
         * Add a plugin to the end of the rack
         *
         * @param plugin AudioPlugin to append to the rack
         */
        public void append (AudioPlugin plugin) throws PluginError {
            if (plugin.category != rack_type) {
                throw new PluginError.INVALID_CATEGORY ("Attempted to add plugin of different category");
            }

            plugins.append (plugin);
            plugin.instantiate ();

            connect_audio_ports ((int) plugins.length () - 1);
        }

        /**
         * Add a plugin to the specified position
         *
         * @param plugin AudioPlugin to add to the rack
         * @param position The position in the stack where the plugin must
         * be added
         */
        public void insert (AudioPlugin plugin, int position) throws PluginError {
            if (plugin.category != rack_type) {
                throw new PluginError.INVALID_CATEGORY ("Attempted to add plugin of different category");
            }

            plugins.insert (plugin, position);
            plugin.instantiate ();

            connect_audio_ports (position);
        }

        /**
         * Remove a plugin from a given position on the rack
         *
         * @param position position in the stack from where the plugin will
         * be removed
         */
        public void remove (int position) {
            AudioPlugin plugin = plugins.nth_data (position);
            plugin.active = false;
            plugins.remove (plugin);

            connect_audio_ports ();
        }

        /**
         * Remove a plugin from the rack
         *
         * @param plugin plugin to remove
         */
        public void remove_data (AudioPlugin plugin) {
            plugin.active = false;
            plugins.remove (plugin);

            connect_audio_ports ();
        }

        /**
         * Activate or deactivate a plugin
         *
         * A plugin will not process audio if it's not active
         *
         * @param position The position of the plugin in the rack
         * @param active Whether the plugin should be enabled or not
         */
        public virtual void set_plugin_active (int position, bool active = true) {
            AudioPlugin plugin = plugins.nth_data (position);
            plugin.active = active;
        }

        /**
         * Process a given stereo audio buffer using plugins
         *
         * @param len Length of buffer to process
         * @param buffer_in_l Audio input buffer for left channel
         * @param buffer_in_r Audio input buffer for right channel
         * @param buffer_out_l Audio output buffer for left channel
         * @param buffer_out_r Audio output buffer for right channel
         */
        public void process_audio (int len, float* buffer_in_l, float* buffer_in_r,
        float** buffer_out_l, float** buffer_out_r) {
            // If the main buffers aren't initialised
            // initialize them
            if (aud_buf_dry_l == null || aud_buf_dry_r == null ||
            aud_buf_mix_l == null || aud_buf_mix_r == null) {
                aud_buf_dry_l = new float[len];
                aud_buf_dry_r = new float[len];
                aud_buf_mix_l = new float[len];
                aud_buf_mix_r = new float[len];
            }

            // Fill main dry buffers with audio data
            for (int i = 0; i < len; i++) {
                aud_buf_dry_l[i] = buffer_in_l[i];
                aud_buf_dry_r[i] = buffer_in_r[i];
            }

            // Process audio using plugins
            run_plugins (len);

            // Fill out buffers using wet mix;
            // Wet mix has been copied to the dry buffer; See below
            for (int i = 0; i < len; i++) {
                * (* buffer_out_l + i) = aud_buf_dry_l[i];
                * (* buffer_out_r + i) = aud_buf_dry_r[i];
            }
        }

        protected void run_plugins (uint32 sample_count) {
            if (active) {
                var rack_thread = new Thread<void> ("rack_thread", () => {
                    foreach (AudioPlugin plugin in plugins) {
                        if (plugin.active) {
                            // Have the plugin process the audio buffer
                            plugin.process (sample_count);

                            // Copy wet audio to dry buffer as per mix amount
                            for (uint32 j = 0; j < sample_count; j++) {
                                aud_buf_dry_l[j] = Utils.Math.map_range_unclampedf (
                                    plugin.mix_gain,
                                    0,
                                    1,
                                    aud_buf_dry_l[j],
                                    aud_buf_mix_l[j]
                                );

                                aud_buf_dry_r[j] = Utils.Math.map_range_unclampedf (
                                    plugin.mix_gain,
                                    0,
                                    1,
                                    aud_buf_dry_r[j],
                                    aud_buf_mix_r[j]
                                );
                            }

                            // Next plugin ready to run
                        }
                    }
                });

                rack_thread.join ();
            }
        }

        protected void connect_audio_ports (int change_index = -1) {
            var was_active = active;
            active = false;

            foreach (AudioPlugin plugin in plugins) {
                plugin.connect_source_buffer (aud_buf_dry_l, aud_buf_dry_r);
                plugin.connect_sink_buffer (aud_buf_mix_l, aud_buf_mix_r);
            }

            active = was_active;
            on_plugin_connect (change_index);
        }
    }
}
