/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.ArrangerWorkstation.Plugins;
using Ensembles.ArrangerWorkstation.Racks;
using Ensembles.Models;

namespace Ensembles.ArrangerWorkstation {
    /**
     * ## Arranger Workstation
     *
     * This forms the core of the app. This houses all the behind the scenes
     * stuff that make every beat beat and every sound sound.
     */
    public interface IAWCore : Object {
        // Signals /////////////////////////////////////////////////////////////
        /** Signals when the arranger is done loading data. */
        public signal void ready();
        /** Sends verbose status for loading screen. */
        public signal void send_loading_status(string status);


        // Functions ///////////////////////////////////////////////////////////
        /**
         * Add directory path where styles are present.
         *
         * @param enstl_dir_path path to the directory containing
         `.enstl` files
         */
        public abstract void add_style_search_path (string enstl_dir_path);
        /**
         * Load all data like voices, styles and plugins.
         */
        public abstract void load_data_async ();
        /**
         * Load all data like voices, styles and plugins.
         */
        public abstract void load_data ();
        /**
         * Get a list of paths from where the styles are searched.
         */
        public abstract unowned List<string> get_style_search_paths ();
        /**
         * Returns an array of styles loaded by the arranger workstation.
         */
        public abstract unowned Style[] get_styles ();
        /**
         * Creates a style engine with given style
         *
         * @param style A Style descriptor
         */
        public abstract void queue_change_style (Models.Style style);
        /**
         * Returns an array of voices loaded by the arranger workstation.
         */
        public abstract unowned Voice[] get_voices ();

        public abstract unowned List<AudioPlugins.AudioPlugin> get_audio_plugins ();

        public abstract unowned Racks.DSPRack get_main_dsp_rack ();

        public abstract unowned Racks.VoiceRack get_voice_rack (
            VoiceHandPosition position
        );

        // Module Interfaces ///////////////////////////////////////////////////
        public abstract AudioEngine.ISynthEngine get_synth_engine ();
        public abstract MIDIPlayers.IStyleEngine get_style_engine ();
    }
}
