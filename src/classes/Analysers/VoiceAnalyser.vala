/*
 * Copyright 2020-2023 Subhadeep Jasu <subhadeep107@proton.me>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Ensembles.Models;
using Ensembles.ArrangerWorkstation.AudioEngine;

namespace Ensembles.ArrangerWorkstation.Analysers {
    public class VoiceAnalyser : Object, IVoiceAnalyser {
        private List<Voice?> voice_list;
        private unowned Fluid.SoundFont soundfont;

        public unowned IAWCore aw_core { private get; construct; }
        public string sf_path { private get; construct; }
        public string sf_schema_path { private get; construct; }

        private List<string> category_id_map;

        public VoiceAnalyser (
            IAWCore aw_core,
            Fluid.Synth utility_synth,
            string sf_path,
            string sf_schema_path
        ) {
            Object (
                aw_core: aw_core,
                sf_path: sf_path,
                sf_schema_path: sf_schema_path
            );

            voice_list = new List<Voice?> ();
            soundfont = utility_synth.get_sfont (0);
        }

        public void analyse_all () {
            FileStream stream = FileStream.open (sf_schema_path, "r");
            string? line = "";
            line = stream.read_line ();
            string category = "";

            uint index = 0;
            unowned Fluid.Preset sf_preset = null;
            soundfont.iteration_start ();
            sf_preset = soundfont.iteration_next ();
            category_id_map = new List<string> ();
            while (sf_preset != null) {
                int preset_num = sf_preset.get_num ();
                int bank_num = sf_preset.get_banknum ();
                var voice_name = sf_preset.get_name ();

                if (line != null) {
                    var parts = line.split (",");
                    int schema_bank = int.parse (parts[0]);
                    int schema_preset = int.parse (parts[1]);

                    if (bank_num == schema_bank && preset_num == schema_preset) {
                        category = parts[2];
                        line = stream.read_line ();
                    }
                }

                voice_list.append (Voice () {
                    index = index++,
                    preset = (uint8) preset_num,
                    bank = (uint8) bank_num,
                    name = voice_name,
                    category = "%03u ".printf (map_category (category)) + category,
                    sf_path = sf_path
                });


                Thread.usleep (15000);
                aw_core.send_loading_status (_("Loading Voice: ") + voice_name + "…");

                sf_preset = soundfont.iteration_next ();
            }

            voice_list.sort ((a, b) => {
                return strcmp(a.category, b.category);
            });

            for (var i = 0; i < voice_list.length (); i++) {
                voice_list.nth_data (i).category = voice_list.nth_data (i).category.substring (4);
            }

            category_id_map = null;
        }

        public Voice[] get_voices () {
            var n = voice_list.length ();
            var voices = new Voice[n];

            for (uint i = 0; i < n; i++) {
                var voice = voice_list.nth_data (i);
                voices[i] = Voice () {
                    name = voice.name,
                    category = voice.category,
                    sf_path = voice.sf_path,
                    preset = voice.preset,
                    bank = voice.bank,
                    index = voice.index
                };
            }

            return voices;
        }

        private uint map_category (string? category) {
            for(uint i = 0; i < category_id_map.length (); i++) {
                if (strcmp (category_id_map.nth_data (i), category) == 0) {
                    return i;
                }
            }

            category_id_map.append (category);
            return category_id_map.length () - 1;
        }
    }
}
