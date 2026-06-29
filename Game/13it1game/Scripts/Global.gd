extends Node2D

enum Game_State {Main_Menu, Controls, Playing_Tutorial, Playing_World, Win}
var current_game_state: Game_State

var num_of_copies_available = 0999
var num_of_undos_available = 0999
var num_of_cuts_available = 0999
var paste_available = false
var selected = false
