namespace Ensembles.Models {
    public class MIDIEvent {
        public enum EventType {
            /** This event is sent when a note is released (ended). */
            NOTE_OFF = 0x80,
            /** This event is sent when a note is depressed (started). */
            NOTE_ON = 0x90,
            /**
             * Polyphonic Key Pressure (Aftertouch).
             * This event is most often sent by pressing down on the key after it
             * "bottoms out".
             */
            KEY_PRESSURE = 0xA0,
            /** This event is sent when a controller value changes.
             * Controllers include devices such as pedals and levers.
             * Certain controller numbers are reserved for specific purposes.
             */
            CONTROL_CHANGE = 0xB0,
            /** This event is sent when the patch number changes. */
            PROGRAM_CHANGE = 0xC0,
            /**
             * Channel Pressure (After-touch).
             * This event is most often sent by pressing down on the key after it
             * "bottoms out". This event is different from polyphonic after-touch.
             * Use this event to send the single greatest pressure value (of all
             * the current depressed keys).
             */
            CHANNEL_PRESSURE = 0xD0,
            /**
             * This event is sent to indicate a change in the pitch wheel.
             */
            PITCH_BEND = 0xE0,
            /** System Exclusive. */
            SYSEX = 0xF0,
            /**
             * Song Position Pointer.
             * This is an internal 14 bit register that holds the number of MIDI
             * beats (1 beat= six MIDI clocks) since the start of the song.
             */
            SONG_POSITION = 0xF2,
            /**
             * Song Select.
             * The Song Select specifies which sequence or song is to be played.
             */
            SONG_SELECT = 0xF3,
            /** End of Exclusive (SysEx).
             * Used to terminate a System Exclusive.
             */
            EOE = 0xF7,
            /**
             * Timing Clock.
             * Sent 24 times per quarter note when synchronisation is required.
             */
            CLOCK_TIMER = 0xF8,
            /**
             * Play the current sequence.
             */
            PLAY = 0xFA,
            /** Continue at the point the sequence was paused. */
            RESUME = 0xFB,
            /** Pause the current sequence. */
            PAUSE = 0xFC,
            /** Active Sensing. */
            ACTIVE_SENSING = 0xFE,
            /**
             * Reset all receivers in the system to power-up status.
             * This should be used sparingly, preferably under manual control.
             * In particular, it should not be sent on power-up.
             */
            RESET = 0xFF
        }

        public enum Control {
            MODULATION = 0x01,
            EXPLICIT_PITCH = 0x03,
            GAIN = 0x07,
            PAN = 0x0A,
            EXPRESSION = 0x0B,
            PITCH = 0x42,
            RESONANCE = 0x47,
            BRIGHTNESS = 0x4A,
            EXPLICIT_BANK_SELECT = 0x55,
            REVERB = 0x5B,
            CHORUS = 0x5D
        }

        public EventType event_type { get; set; }
        public uint8 channel { get; set; }
        public Control control { get; set; }
        public uint8 value { get; set; }
        public uint8 velocity { get; set; }
        public uint8 key { get; set; }
        public uint8 pitch { get; set; }
        public string? text { get; set; }
        public string? lyrics { get; set; }

        public MIDIEvent of_type (EventType event_type) {
            this.event_type = event_type;
            return this;
        }

        public MIDIEvent on_channel (uint8 channel) {
            this.channel = channel;
            return this;
        }

        public MIDIEvent controlling (Control control) {
            this.control = control;
            return this;
        }

        public MIDIEvent with_value (uint8 value) {
            this.value = value;
            return this;
        }

        public MIDIEvent with_key (uint8 key) {
            this.key = key;
            return this;
        }

        public MIDIEvent of_velocity (uint8 velocity) {
            this.velocity = velocity;
            return this;
        }

        public MIDIEvent pitch_shifted_by (uint8 pitch) {
            this.pitch = pitch;
            return this;
        }

        public MIDIEvent with_text (string? text) {
            this.text = text;
            return this;
        }

        public MIDIEvent with_lyrics (string? lyrics) {
            this.lyrics = lyrics;
            return this;
        }
    }
}
