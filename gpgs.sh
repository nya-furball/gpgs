#!/bin/sh


UMASK_ORIG="$(umask)"
UID_SESSION="$(openssl rand -hex 16)";	# session UUID
GPG_TEMPDIR="$(mount|grep -e tmpfs |cut -d ' ' -f 3|grep -e shm)/gpgs-session-${UID_SESSION}"


# initialize gpg_dir
# prototype:
#	gpg_initialize userid algo expire passphrase;
UID_PREFIX="test-"	# name or identifier, CUSTOMIZE HERE!
UID_FULL="${UID_PREFIX}session-${UID_SESSION}"	# full UID of session keypair
GPG_PASSPHRASE="$(openssl rand -hex 32)"
GPG_FINGERPRINT="";
GPG_PUBKEY="";
gpg_initialize(){
	# vanity vars
	local uid="$1";
	local algo="$2";
	#local usage="$3";
	local expire="$3";
	local passphrase="$4";
	
	# generate session keypair
	gpg --homedir ${GPG_TEMPDIR} --batch --quiet --passphrase "${passphrase}" --pinentry-mode loopback --expert --quick-gen-key ${uid} ${algo} sign ${expire};
	
	# extract fingerprint
	
	GPG_FINGERPRINT="$(gpg --homedir ${GPG_TEMPDIR} --no-emit-version --batch --quiet -k ${uid}|grep -A1 pub|tail -n1|sed -e 's/ //g')"
	# add encyrption subkey
	if [ "${algo}" = "ed25519" ]; then {
		algo="cv25519";
	}
	fi;
	gpg --homedir ${GPG_TEMPDIR} --batch --quiet --passphrase "${passphrase}" --pinentry-mode loopback --expert --quick-add-key ${GPG_FINGERPRINT} ${algo} encr ${expire};

	# prompt
	GPG_PUBKEY="$(gpg --batch --quiet --homedir "${GPG_TEMPDIR}" -a --export "${GPG_FINGERPRINT}" )"
	printf "\n\nHERE IS YOUR SESSION FINGERPRINT:\n%s\n\nHERE IS YOUR SESSION PUBKEY: \n%s\n\n" "${GPG_FINGERPRINT}" "${GPG_PUBKEY}";
	promptContinue;
}


# command list
GPGSD_COMMANDS="Note: Import and Decrypt support one-liner input.
Commands:
I:	Import recipient's session pubkey and/or set key to encrypt to.
E:	Encrypt and sign a message to recipient's session.
D:	Decrypt message sent to this session.
S:	Clearsign message with this session.
V:	Verify messages sent to this session.
P:	Print your session fingerprint and public key.
O:	Convert pubkey/messages w/ newlines to a one-liner
M:	Convert a one-liner back to a pubkey/message w/ newline.
Q:	Quit session. (ctrl+C or interrupts also work).
"

# user interface loop
# prototype:
#	gpgsd;
GPG_RECIPIENT="";
gpgsd(){
	local run=1;
	local input="";
	local imported=0;
	while [ "$run" = "1" ]; do {
		# prompt user for action
		input="";
		printf "%s\nEnter command: " "${GPGSD_COMMANDS}";
		read input;
		
		# parse input
		case "${input}" in
			"I"|"i")
				# import key
				printf "Paste in recipient's pubkey: (ctrl+D after paste or to skip)\n"
				input="$(cat)"
				printf "%s\n" "${input}"|tr "&" "\n"|gpg --homedir ${GPG_TEMPDIR} --batch --quiet --import -a;
				# get recipient fingerprint\
				printf "\nFollowing keys are in keychain:\n";
				gpg --homedir ${GPG_TEMPDIR} --batch --quiet -k;
				printf "TIP: if importing, look for key with unknown trust level.\n";
				printf "Enter recipient's fingerprint: ";
				read GPG_RECIPIENT;
				# trust recipient key
				printf "5\ny\n\n" | gpg --homedir ${GPG_TEMPDIR} --batch --quiet --command-fd 0 --edit-key "${GPG_RECIPIENT}" trust;
				;;
			"E"|"e")
				# encrypt to recipient
				printf "Message to encrypt: (ctrl+D when done)\n";
				gpg --homedir ${GPG_TEMPDIR} --no-emit-version --batch --quiet --passphrase "${GPG_PASSPHRASE}" --pinentry-mode loopback -ase --no-throw-keyids -R "${GPG_RECIPIENT}" --personal-digest-preferences "SHA512 SHA384 SHA256";
				printf "\n";
				;;
			"D"|"d")
				# decrypt
				printf "Enter message to decrypt: (ctrl+D when done)\n"
				input="$(cat)"
				printf "\nDecrypted message:\n";
				printf "%s\n" "${input}"|tr "&" "\n"|gpg --homedir ${GPG_TEMPDIR} --batch --quiet --passphrase "${GPG_PASSPHRASE}" --pinentry-mode loopback --decrypt -a;
				printf "\n";
				;;
			"S"|"s")
				# clearsign
				printf "Enter your message to clearsign: (ctrl+D to end)\n";
				gpg --homedir ${GPG_TEMPDIR} --no-emit-version --batch --quiet --passphrase "${GPG_PASSPHRASE}" --pinentry-mode loopback --clearsign --personal-digest-preferences "SHA512 SHA384 SHA256";
				printf "\n";
				;;
			"V"|"v")
				# verify
				printf "Enter message to verify: (ctrl+D to end)\n";
				gpg --homedir ${GPG_TEMPDIR} --batch --quiet --verify;
				printf "\n";
				;;
			"Q"|"q")
				# quit
				run=0;
				;;
			"P"|"p")
				# show pubkey and fpr
				printf "\n\nHERE IS YOUR SESSION FINGERPRINT:\n%s\n\nHERE IS YOUR SESSION PUBKEY: \n%s\n\n" "${GPG_FINGERPRINT}" "${GPG_PUBKEY}";
				promptContinue;
				;;
			"O"|"o")
				# convert to one-liner
				printf "Press ctrl+D when done pasting:\n";
				cat | tr "\n" "&"|sed -E -e 's/(.$)/\1\n\n/' -e 's/(^.)/\n\nHere is your one liner:\n\1/';
				;;
			"M"|"m")
				printf "Press ctrl+D when done pasting:\n";
				input="$(cat)";
				printf "\n\nHere is the original: \n%s\n\n" "$(echo ${input}|tr "&" "\n")";
				input="";
				;;
			*)
				# invalid command
				printf "Invalid command.\n\n";
				;;
		esac;
			
	}
	done;
}

initialize(){
	# prompt users about stop and start
	printf "If you accidentally pressed ctrl+S, press ctrl+Q to unpause terminal!!!\n";
	printf "Use ctrl+\\ to emergency quit!\n";
	printf "Don't forget to customize your UID_PREFIX in the script!\n";
	promptContinue;
	umask 077;
	
	# initialize program
	mkdir "${GPG_TEMPDIR}";
	gpg_initialize "${UID_FULL}" "ed25519" "1d" "${GPG_PASSPHRASE}";
}


cleanup(){
	# overwrite master key
	GPG_PASSPHRASE="$(openssl rand -hex 32)";
	
	# kill gpgagent to clear passphrase caching
	gpgconf --homedir "${GPG_TEMPDIR}" --kill all;
	
	# print revokecation cert
	local revoke="$(cat "${GPG_TEMPDIR}/openpgp-revocs.d/${GPG_FINGERPRINT}.rev"|awk '/BEGIN PGP PUBLIC KEY BLOCK/ { found=1; } found {print} /END/ { found = 0 ;}'|sed -E -e 's/^://g';)"
	printf "\n\nHERE IS YOUR REVOKATION:\n%s\n\n" "${revoke}";
	
	rm -rf "${GPG_TEMPDIR}";
	umask ${UMASK_ORIG};
}


ramcheck(){
	# check if /dev/shm or /var/run/shm exists
	if [ "$(printf "${GPG_TEMPDIR}"|grep '/shm/')" = "" ]; then {
		printf "/dev/shm not detected. Exiting.\n";
		exit 1;
	}
	fi;
	
	# check for non-volatile swapfile and exit if found
	if [ "$(cat /proc/swaps|tail -n+2|sed -e '/zram/d')" != "" ]; then { 
		printf "Warning: there are active swapfiles/partitions!\nKey can be swapped into non-volatile storage! Exiting.\n" ; 
		exit 1;
	}
	fi;
}


promptContinue(){
	local temp;
	printf "Press enter to continue: "
	read temp;
}


confirmExit(){
	# trap interrupts
	trap "" HUP;    # SIGHUP
	trap "" INT;    # SIGINT, ctrl + c
	trap "" TERM;   # SIGTERM
	
	# confirmation prompt
	printf "\n\nDo you want to exit? (Y/n): ";
	local prompt;
	read prompt;
	case  "${prompt}" in
		"Y"|"y")
			cleanup;
			exit;
			;;
		*)
			# reconfigure interrupts
			trap "confirmExit;" HUP;    # SIGHUP
			trap "confirmExit;" INT;    # SIGINT, ctrl + c
			trap "confirmExit;" TERM;   # SIGTERM
			;;
	esac;
}


main(){
	ramcheck;
	initialize;
	
	# main loop
	gpgsd;
	
	cleanup;
	exit 0;
}

# trap interrupts
trap "confirmExit;" HUP;	# SIGHUP
trap "confirmExit;" INT;	# SIGINT, ctrl + c
trap "cleanup; exit;" QUIT;	# SIGQUIT, ctrl + \
trap "confirmExit;" TERM;	# SIGTERM
trap "" TSTP;			# SIGTSTP, ctrl + Z


main;
