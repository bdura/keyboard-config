#include QMK_KEYBOARD_H

enum layers {
    _QWERTY,
    _COLEMAK_DH,
    _ARROWS,
    _NUMBERS,
    _SYMBOLS
};

#define _______COLEMAK_DH_L1_______     KC_Q,         KC_W,         KC_F,         LT(_ARROWS,KC_P), KC_B
#define _______COLEMAK_DH_L2_______     CMD_T(KC_A),  ALT_T(KC_R),  SFT_T(KC_S),  CTL_T(KC_T),      ALGR_T(KC_G)
#define _______COLEMAK_DH_L3_______     KC_Z,         KC_X,         KC_C,         KC_D,             KC_V

#define _______COLEMAK_DH_R1_______     KC_J,         KC_L,         KC_U,         KC_Y,             KC_SCLN
#define _______COLEMAK_DH_R2_______     ALGR_T(KC_M), RCTL_T(KC_N), RSFT_T(KC_E), ALT_T(KC_I),      RCMD_T(KC_O)
#define _______COLEMAK_DH_R3_______     KC_K,         KC_H,         KC_COMM,      KC_DOT,           KC_SLSH

#define _________QWERTY_L1_________     KC_Q,         KC_W,         KC_E,         LT(_ARROWS,KC_R), KC_T
#define _________QWERTY_L2_________     CMD_T(KC_A),  ALT_T(KC_S),  SFT_T(KC_D),  CTL_T(KC_F),      ALGR_T(KC_G)
#define _________QWERTY_L3_________     KC_Z,         KC_X,         KC_C,         KC_V,             KC_B

#define _________QWERTY_R1_________     KC_Y,         KC_U,         KC_I,         KC_O,             KC_P
#define _________QWERTY_R2_________     ALGR_T(KC_H), RCTL_T(KC_J), RSFT_T(KC_K), ALT_T(KC_L),      RCMD_T(KC_SCLN)
#define _________QWERTY_R3_________     KC_N,         KC_M,         KC_COMM,      KC_DOT,           KC_SLSH

#define ___BASE_LT___     LT(_SYMBOLS,KC_ESC), LT(_NUMBERS,KC_ENT)
#define ___BASE_RT___     MEH_T(KC_SPC),         LT(_SYMBOLS,KC_BSPC)

// U+I+O chord toggles Caps Word.
// Combos match the keycode at each position, so this only fires on QWERTY,
// where the three keys are plain top-row keys.
const uint16_t PROGMEM uio_combo[] = {KC_U, KC_I, KC_O, COMBO_END};

combo_t key_combos[] = {
    COMBO(uio_combo, CW_TOGG),
};

#define LAYOUT_ferris_wrapper(...)   LAYOUT(__VA_ARGS__)

// clang-format off
const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    /*
    *   ┌───┬───┬───┬───┬───┐   ┌───┬───┬───┬───┬───┐
    *   │ Q │ W │ E │①/R│ T │   │ Y │ U │ I │ O │ P │
    *   ├───┼───┼───┼───┼───┤   ├───┼───┼───┼───┼───┤
    *   │◆/A│⎇/S│⇧/D│⎈/F│▣/G│   │▣/H│⎈/J│⇧/K│⎇/L│◆/;│
    *   ├───┼───┼───┼───┼───┤   ├───┼───┼───┼───┼───┤
    *   │ Z │ X │ C │ V │ B │   │ N │ M │ , │ . │ / │
    *   └───┴───┴───┼───┼───┤   ├───┼───┼───┴───┴───┘
    *               │➂/⎋│➁/⏎│   │ ⎵ │➂/⌫│
    *               └───┴───┘   └───┴───┘
    */
	[_QWERTY] = LAYOUT_ferris_wrapper(
		_________QWERTY_L1_________, _________QWERTY_R1_________,
		_________QWERTY_L2_________, _________QWERTY_R2_________,
		_________QWERTY_L3_________, _________QWERTY_R3_________,
		___BASE_LT___,               ___BASE_RT___
	),
	[_COLEMAK_DH] = LAYOUT_ferris_wrapper(
		_______COLEMAK_DH_L1_______, _______COLEMAK_DH_R1_______,
		_______COLEMAK_DH_L2_______, _______COLEMAK_DH_R2_______,
		_______COLEMAK_DH_L3_______, _______COLEMAK_DH_R3_______,
		___BASE_LT___,               ___BASE_RT___
	),
    [_ARROWS] = LAYOUT(
        KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, QK_BOOT, KC_NO,   KC_NO, KC_NO,   KC_NO,
        KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_LEFT, KC_DOWN, KC_UP, KC_RGHT, KC_NO,
        KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,   KC_NO,   KC_NO, KC_NO,   KC_NO,
                             KC_NO, KC_NO, KC_NO,   KC_NO
    ),
    [_NUMBERS] = LAYOUT(
        KC_TAB,       KC_NO,        KC_NO,        KC_NO,        KC_NO,         KC_NO, KC_1, KC_2, KC_3, KC_MINUS,
        CMD_T(KC_NO), ALT_T(KC_NO), SFT_T(KC_NO), CTL_T(KC_NO), ALGR_T(KC_NO), KC_NO, KC_4, KC_5, KC_6, KC_0,
        KC_NO,        KC_NO,        KC_NO,        KC_NO,        KC_NO,         KC_NO, KC_7, KC_8, KC_9, KC_0,
                                                  KC_NO,        KC_NO,         KC_NO, KC_NO
    ),
    [_SYMBOLS] = LAYOUT(
        KC_1,          KC_2,          KC_3,          KC_4,          KC_5,          KC_6,             KC_7,            KC_8,            KC_9,          KC_0,
        LGUI_T(KC_NO), LALT_T(KC_NO), LSFT_T(KC_NO), LCTL_T(KC_NO), RALT_T(KC_NO), RALT_T(KC_MINUS), RCTL_T(KC_LBRC), RSFT_T(KC_RBRC), LALT_T(KC_NO), RGUI_T(KC_NO),
        KC_NO,         KC_NO,         KC_NO,         KC_NO,         KC_NO,         KC_NO,            KC_NO,           KC_NO,           KC_NO,         KC_NO,
                                                     KC_NO,         KC_NO,         KC_NO,            KC_NO
    ),
};
// clang-format on
