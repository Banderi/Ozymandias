extends Node

const MAX_MESSAGES = 1000
const MESSAGE_CATEGORIES = 20

var total_messages_passed = 0
var total_messages_current = 0
var last_message_id_highlighted = 0
var census_messages_received = []
var message_counts = []
var message_delays = []
