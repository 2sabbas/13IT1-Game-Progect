extends Node2D

enum Game_State {Main_Menu, Controls, Playing_Tutorial, Playing_World, Win}
var current_game_state: Game_State

var initial_num_of_copies_available = 99
var initial_num_of_undos_available = 99
var initial_num_of_cuts_available = 99
var initial_paste_available = false
var initial_selected = false

var num_of_copies_available = 0
var num_of_undos_available = 0
var num_of_cuts_available = 0
var paste_available = false
var selected = false

var instruction_visible = false
var instruction_message = ""
