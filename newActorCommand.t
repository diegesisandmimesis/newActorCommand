#charset "us-ascii"
//
// newActorCommand.t
//
// Implements the newActorCommand() function, which allows commands to
// be executed as if they were typed in the command line by a specified actor.
//
// For example, if you have an Actor bob...
//
//	newActorCommand(bob, 'north');
//
// ...would execute the command >NORTH with bob as the gActor, and...
//
//	newActorCommand(bob, 'take pebble');
//
// ...would have bob try to >TAKE PEBBLE.
//
// This is substantially less efficient than adv3's native newActorAction(), 
// but it allows commands to be constructed at runtime (for, for example, NPC
// scripting) without having to resort to a forest of conditionals.
//
#include <adv3.h>
#include <en_us.h>

// Module ID for the library
newActorCommandModuleID: ModuleID {
        name = 'newActorCommand Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

// Executes a command (or tries to), returning a transcript of the
// results, and then resets the game state to the way it was before the
// command was executed.
newActorCommandTranscript(src, dst, toks, first) {
	local tr;

	tr = gTranscript;
	try {
		savepoint();
		gTranscript = new CommandTranscript();
		executeCommand(src, dst, toks, first);
		return(gTranscript);
	}
	finally {
		undo();
		gTranscript = tr;
	}
}

// Returns boolean true of the given command would succeed, nil otherwise.
newActorCommandCheck(src, dst, toks, first) {
	return(!(newActorCommandTranscript(src, dst, toks, first)).isFailure);
}

// Checks to see if the specified command would succeed and if so, execute
// it "for real".
tryNewActorCommand(src, dst, toks, first) {
	if(!newActorCommandCheck(src, dst, toks, first))
		return(nil);

	executeCommand(src, dst, toks, true);

	return(true);
}

// Try to execute the given command as if it was typed at the command
// line by the given actor.
newActorCommand(actor, cmd) {
	local toks;

	if((actor == nil) || !actor.ofKind(Actor) || (cmd == nil))
		return(nil);

	toks = cmdTokenizer.tokenize(cmd);
	if(toks == nil)
		return(nil);

	return(tryNewActorCommand(actor, actor, toks, true));
}
