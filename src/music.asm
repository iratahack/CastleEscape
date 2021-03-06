        public  PLAYER_INIT
        public  PLAYER_OFF
        public  LOAD_SONG
        public  START_SONG
        public  START_SOUND
        public  INTERR

        section BANK_5

		;
		; Assembly player from https://github.com/AugustoRuiz/WYZTracker
		;
		; Minor tweaks to change some routine names to English
		;
        include "wyzproplay47c_zx.inc"

        section rodata_user
		;
		; Table of songs...
		;
TABLA_SONG:
        dw      SONG_0, SONG_1, SONG_2

        ;
        ; Instrument configuration exported from WYZTracker
        ;
        include "music/CastleEscape.mus.inc"

		;
		; Songs exported from WYZTracker
		;
SONG_0:
        binary  "music/gothic.mus"
SONG_1:
        binary  "music/jinj_med.mus"
SONG_2:
        binary  "music/death.wyz.mus"
