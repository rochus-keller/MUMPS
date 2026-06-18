%HELPH  ;26-Apr-85 ;DSM-11 ;UTILITIES ;EXPLAIN THE STUPID HELP EDITOR ;RWB
        W !,?15,"THE %HELPED EDITOR"
        W !
        S J="G1" S I=1 D PRINT
A1      R !,"COMMAND:  ",Z
        W !
        I (Z="Q")!(Z="q")!(Z="") K I,J,K,Z Q
        I "fuodrlmcixensbth"[Z S Z=$C($A(Z)-32)
        I (Z'?1A)!'("FUODRLMCIXENSBTH"[Z) W !,"Whads da mattah wit you, buddy, type a single letter command already!",! G A1
        S J=Z S I=1 D PRINT W ! S J="G1" S I=15 D PRINT G A1
PRINT   F I=I:1 S K=$P($T(@J+I),";;",2) Q:K["STOP"  W !,K
        Q
G1      ;;
        ;;This editor is used for modifying the %HELP11 on-line documentation
        ;;global. The %HELP11 global has a tree structure which is used by
        ;;the %HELPMEN routine to print out the help texts. At each level of
        ;;the tree, there are option messages, text, and then the options
        ;;themselves, which have the same structure. If subtopic options
        ;;will be available at the level, the first node should contain "\".
        ;;The text is in nodes with the last subscripts increasing integers.
        ;;Following these nodes are the option nodes. Do a %G on ^%HELP11
        ;;to see this structure more clearly.
        ;;
        ;;*** DISCLAIMER ***  This is a weird little editor.
        ;;
        ;;The following commands are supported:
        ;;
        ;;U - Up       D - Down     R - Right    L - Left     T - Top
        ;;N - New      X - Delete   C - Change   I - Input    M - Multiple
        ;;E - Display  S - Save     B - Exit     O - Text add and delete
        ;;F - Format   H - Help
        ;;
        ;;Type "Q" or <RETURN> to quit.
        ;;
        ;;STOP
U       ;;
        ;;The highest subscript is stripped from the current node,
        ;;except if the current node is the top node, in which
        ;;case it is left unchanged. U allows one to move up the %HELP11
        ;;global tree.
        ;;STOP
D       ;;
        ;;The first node in collating order at the next highest level
        ;;is made the current node. If no higher level exists, the
        ;;current node remains unchanged. This allows one to move down the
        ;;global tree.
        ;;STOP
R       ;;
        ;;The next node in collating order at the same level as the current
        ;;node is made the current node. If no further node exists at the
        ;;level of the curent node, it is not changed. This allows one to
        ;;move horizontally accross the global %HELP11.
        ;;STOP
L       ;;
        ;;The previous node in collating level at the same level as the
        ;;current node is made the current node. If no previous node
        ;;exists at the level of the current node, it is left unchanged.
        ;;This allows for horizontal movement accross the %HELP11 global.
        ;;STOP
T       ;;
        ;;The top node of the %HELP11 global is made the current node.
        ;;STOP
N       ;;
        ;;A new node at the next highest level from the current node is created.
        ;;The new unique subscript should be typed after the ":" prompt.
        ;;Then the entire reference is printed, and the user is asked
        ;;whether or not to create the node. If "Y" is answered, the node
        ;;is created, and it's value can be typed after the ensuing ":"
        ;;prompt. The current node becomes the new node. If no value is
        ;;entered, the node is assigned the value "X".
        ;;STOP
X       ;;
        ;;The current node (except for the top node, which cannot be
        ;;deleted) is deleted if the last part of its subscript is not
        ;;a number. In effect, this command deletes subtrees from the
        ;;%HELP11 global, but not text within the subtree.
        ;;STOP
C       ;;
        ;;This is similar to the C command in ^%EDI. However, the changes
        ;;do not follow the C. A new line with a ":" prompt is printed.
        ;;Then the user types the old text, a "??" separator, and the
        ;;new text, e.g. :fred and martha??fred and hildegaard
        ;;STOP
I       ;;
        ;;This command erases the current contents of a node, and gives
        ;;the user a ":" prompt after which the new contents can be
        ;;typed. If no new contents are typed, the node is set to "X".
        ;;STOP
M       ;;
        ;;This commands allows the commands U, D, R, L, and F to act
        ;;repetitively. After typing in M, a ":" prompt is given.
        ;;At this prompt, the user types the command to be repetitively
        ;;executed, followed immediately by the number of times it is
        ;;to be executed, e.g. R5. In the case of F, a blank line will
        ;;terminate the M command. Also, the F arguments will be asked
        ;;only once, at the beginning of the execution. If F causes a
        ;;line of text to be deleted, the following nodes' subscripts
        ;;are automatically adjusted.
        ;;STOP
E       ;;
        ;;Displays the current node.
        ;;STOP
S       ;;
        ;;Saves all changes since the start of the editing session to
        ;;%HELP11. Changes are originally made to a temporary copy,
        ;;%TEMP.
        ;;STOP
B       ;;
        ;;Exits from %HELPED. One must save changes before exiting, if
        ;;they are to be permanently made to %HELP11.
        ;;STOP
O       ;;
        ;;This command deletes or adds numbered text nodes. The first
        ;;text node, with the final subscript being 1, must already
        ;;first exist. This node cannot be deleted with O or X. The
        ;;node which contains it must be deleted to get rid of it.
        ;;After the ":" prompt, type the number of nodes to insert or
        ;;delete. If nodes are inserted, they are given the value "X".
        ;;Subsequent nodes' subscripts are automatically adjusted.
        ;;The user is then asked whether to add or delete nodes. It's
        ;;OK to delete more than actually exist.
        ;;STOP
F       ;;
        ;;This is the only unique and good thing about this editor.
        ;;It does a text format of the line (or lines, using first the M
        ;;command) like runoff. After the prompt, one types the beginning
        ;;and ending points for the line, or LEFT MARGIN and RIGHT MARGIN
        ;;in runoff parlance. Using M, whole blocks of text are automatically
        ;;formatted.
        ;;STOP
H       ;;
        ;;You're doing it, pal.
        ;;STOP
