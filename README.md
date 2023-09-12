# Introduction to vm and usage guide 

## What does it do, what is it good for?

### It runs qemu and friends

Rather than trying to replace `virsh`, it is aimed at people who do not
wish to deal with the overhead that comes with the ability to manage 
dozens of virtual machines which are similar in nature and serve
similar purposes. If you have only one or two instances in production
and/or keep a few around for experiments but want some sort of
consistency in your way of handling those installations, `vm` is for you.

### It is simple and lightweight

Think of it as a replacement for the collection of shell scripts that
tend to pile up when you work with programs that have a lot of 
command line options (also known as magical incantations). While being flexible
and easy to modify because it is basically only a central repository 
for several wrapper scripts, vm still provides:

- **configurability** 

There are a plethora of environment variables that
you can set and store in one single file per virtual machine
to adapt vm's behaviour to your needs. You can even define your own and
use them in your user-provided scripts.

- **error handling** 

Vm performs a lot of sanity checks before doing something 
that you might later regret. It also tries to tell you exactly what went wrong 
should an operation fail.

- **logging**

A simple yet effective logging mechanism makes it
suitable for unattended use, e.g. started in the background at system bootup.

- **state preservation and backup**

Whether you want to freeze the guest os in its current state so that 
you can later continue where you left off, e.g. after rebooting the host computer, 
save a memory snapshot in case something goes wrong, or need to suspend/shutdown 
the emulator in order to make backup copies of your disk images, vm
can do all that with one single command. 

It can also completely archive your 
virtual machine for future reference and crash recovery. Backing files
and compression are supported which means that when you create a checkpoint, 
only the part that has actually changed will be copied out, thereby
mimimizing disk space requirements.

## How do I install vm?

There isn't really an installation process, since vm is quite self-contained.
The starting point is the script aptly named `vm` that is located in
`<installdir>/bin`. Add this to your PATH, link the script to wherever
your system can find it, e.g. `/usr/local/bin`, or call it directly specifying the full 
path, it doesn't matter. 

The only other requirement is that `vm` needs to know
where to find its library. If you put it in `/usr/local/vm` you
are already done since that is the default. Otherwise you can either
edit the default path in `bin/vm` or set the variable `VM_LIB` to 
`<installdir>/lib`, possibly in `/etc/environment`. 

In other words, calling it like so: 
`VM_LIB=/home/me/progs/vm/lib /home/me/progs/vm/bin/vm` will do just fine.

## How do I set up a virtual machine for use with vm?

### Install the guest operating system

There are a few conventions that need to be explained, but it is probably 
simplest to just walk you through the complete process.

First of all, you must produce a disk image with a working installation
of the guest operating system on it. Vm does not handle this because
it is needed only once, the process can vary, and your favourite distro 
will probably provide instructions for it anyway. 

For the purpose of this example, we will use Guix as our guest of choice. First, 
create a directory where your Guix installation will live. We will simply 
call it`guix`:

    mkdir guix
    cd guix

Now download the GNU Guix System .iso file (*not* the ready-made QEMU image)
from the [Guix download page](https://guix.gnu.org/en/download/), then follow the
instructions found
[here](https://guix.gnu.org/manual/en/html_node/Installing-Guix-in-a-VM.html).

**Important:** Please check the box next to 'OpenSSH secure shell daemon (sshd)' 
when the installer asks for networking services, vm needs it. 
You could add the package later, but we will not cover that process here.

Now it is time to create the configuration file. It is named `.vmrc` - 
every directory which contains exactly one virtual machine has exactly
one of these. Paste this into it:

    VM_MACHINE_NAME=guix
    VM_MACHINE_ID=33
    VM_MACHINE_OWNER=daniel
    VM_MACHINE_USER=guido
    VM_MACHINE_MEM=1024

Change `VM_MACHINE_OWNER` to the name of the user account you are currently 
logged into. Change `VM_MACHINE_USER` to the name of the user account you
created while installing Guix, or delete the line if both are identical. 

`VM_MACHINE_ID` can be anything from 01 to 99,
but note that two digits are required and they must be different
across all the machines that you want to run at the same time.

`VM_MACHINE_MEM` obviously refers to the amount of memory that qemu will 
allocate, in Megabytes.

We will start to use snapshots right away. There is no downside to it,
and the ability to work without them is mainly provided for compatibility
with existing images. You can set `VM_USE_SNAPSHOTS=no` in the configuration,
but then much of vm's functionality will not be available.

Note that in this context, the word "snapshot" refers to image 
files containing only the part of the whole virtual disk that has been written 
to, which are called *backing files*. The one containing all the rest
is called the *base file*. This can be confusing because qemu calls the
system state, memory etc., that it saves to the image file ... snapshot.

For snapshots to work, there is one last step necessary, which will fortunately
be taken care of by vm already. You should be the proud owner of a file called
`guix-system.img` that contains the virtual machine that will be known as `guix`.
Vm expects image files in the qcow2 format to end in .qcow2. It also wants
to use a file named `guix-seed.qcow2` as a starting point for creating the
files it will actually work with. Thusly: 

    mv guix-system.img guix-seed.qcow2

Note that this has nothing to do with the name of the directory the virtual
machine lives in, you can rename the directory, move it to a different location, 
what counts is the `.vmrc` stored alongside the images. 

Now how does vm find those files anyway? 
Easy: it looks in your current working directory first, so in order to 
work with Guix, `cd ~/guix`, and, say, Alpine Linux,
`cd /usr/local/alpine`. Then it evaluates the environment variable `VM_HOME`
so if you want to be able to cd around in the file system while still working
with Guix, `export VM_HOME=~/guix`. If you cd to the home of another virtual
machine that is not Guix, which would be confusing, vm will issue an 
error message. You can suppress this behaviour by setting
`VM_HOME_OVERRIDES_CWD` to `yes`.

Time to create those files already! Type in

    vm init --verbose

and watch the show.

If all goes well, you will now have two files named
`guix-base.qcow2` and `guix-backing.qcow2`, respectively. Those are
all that vm is ever going to look at, therefore you can delete
`guix-seed.qcow2` or keep it in case you want to
re-create the virtual machine from scratch without going through
the installation process again.

Finished! It is now time to ...

### Run the virtual machine

    vm run --nat --verbose &
    
In case your version of qemu is compiled to display the guest in a window
by default, which it probably is, ~~your sauce should now have a smooth, brown~~
this is indeed what should appear. The command line that vm displays because
of the `--verbose` switch represents all that it does in this instance,
construct the command line and run qemu in the foreground. Note
the use of the `VM_MACHINE_ID` to construct a unique port number to start the vm 
monitor network service on. For this reason, pressing `ctrl-alt-f2` won't
 work as you might expect. You do not, however, need to use telnet or
netcat to talk to qemu, there being `vm cmd` to do just that.

    vm cmd info status -v
    
Please be aware that the connection check is only performed when you use the 
`--verbose` switch and is for informational purposes only. When
a connection cannot be established, `vm cmd` will fail silently.
While this may seem like a stupid oversight, there is a reason for this, namely
that qemu in some cases does just the same, i.e. say nothing if a command did
not complete successfully or even has not completed at all. Vm tries to check 
for the desired result to appear where possible - for example, after sending
`quit` it usually waits for the qemu process to go away - and, well, 
otherwise we'll just have to keep our fingers crossed, won't we.
    
Now you could use this yourself to send the `quit` command to qemu 
(or just close the window), but there is a slightly more elegant way to 
shut it down:

    vm kill    
    
This will inform you if the emulator was not running in the first place,
check whether it is reachable before attempting to send the `quit` command, 
and make sure that the qemu process is indeed gone in the end by killing it 
if necessary (and inform you about that if you use the `--verbose` switch). Once
again, it can use the machine id to make sure that it catches the correct
process to go with the directory you are currently working with.

That's basically how it all works. 

One other thing worth noting is that in order to save the output of the vm 
commands to a log file, you do not have to redirect anything. 
Instead you can set the variables `VM_LOG` and `VM_ERRLOG` in the environment 
or the `.vmrc` as usual. This works independently of the `--verbose` switch,
the messages that will be logged are selected based on how meaningful they
are in a non-interactive context.

### Set up networking

So far we have used qemu's capabiliy of what is commonly referred to as
sharing your network connection with the guest (that's what the `--nat` switch
is for; NAT stands for *network address translation*)
which is fine for accessing the internet and does not require any privileges.

It does not, however, lend itself to offering services on the guest itself,
specifically you can't log into it from the outside,
which is exactly what vm needs to do to in order to perform most of its
higher-level functions.

So how do we fix this?

First of all, you will have to use `vm run` and later `vm start` with root 
privileges. I recommend giving yourself unrestricted access to vm:

    echo 'daniel ALL = NOPASSWD: /usr/local/bin/vm' | sudo tee /etc/sudoers.d/vm

so that sudo won't ask for a password. If you are currently
already using Guix you will have to reconfigure your system instead because
changes you make to system files will be clobbered at reboot. See below
at the end of this section for how that works.

Using sudo is necessary because vm has to add a separate network interface for 
the guest os that qemu can then get its hooks into. This is called a *bridge* 
and basically results in the guest os having a wired connection that seems to be 
connected alongside your computer, not to it, as if both were plugged in to the 
same router or switch.

If you already have a bridge interface configured - which had better be
called `br0`, or else you will need to modify `lib/vm-run.sh` - vm will detect
it and let qemu do all the work, which incidentally happens in a script
called `/etc/qemu-ifup`. Consult this for more information. 

If unsure, enter:

    ip address show dev br0

If it says

>Device "br0" does not exist.

fret not. You are almost certainly using NetworkManager 
(my Ubuntu on which I'm writing this certainly does, so do a lot of other 
distributions, incluing Guix) and vm can instruct it to create the bridging 
interface on the fly (and delete it when it's done). Try:

    sudo vm run -v
    
Vm should spit out a few lines talking about added connections and
after qemu has stopped, the same about deleted ones. If your Guix window does 
not appear, you are out of luck. You will almost certainly have to resort
to creating the above mentioned `br0` interface by hand which is
beyond the scope of this document - and the process will vary between 
distributions.

It is now time to configure the network on the guest. This
is the slightly trickier part because it can depend on your environment and,
of course, the guest os you have installed. 

The good news is that, if your computer gets configured automatically for
internet access, for instance by a router or wlan hotspot, 
you are probably already done! The guest will receive the
same treatment and that's all that is required. If not, manually give it
an ip address on the same subnet as your computer. If you don't know how
to do that, ask someone who does.

For the sake of this document we will stick to the Guix example and 
assume that you are using the GNOME desktop. Log in, click somewhere
in the middle, then right click somewhere and choose "Settings". 

Before you turn to the Network settings, choose "Power" from the menu on
the left hand side and set "Automatic Suspend" to "off" - otherwise
Guix will just freeze after a period of inactivity and vm will
not be able to do anything with it (cron jobs won't run either)! 

Now click on "Network" - under "Wired" it should say 
"Connected - 1000Mb/s". If not you will have to fiddle with the 
settings, see above. Click on the cog icon to the right to see what's cooking
and note down the IPv4Address displayed. 

On Debian/Ubuntu systems and others that use NetworkManager this information 
can usually be gleaned by clicking on some network related icon in one of the 
corners of the screen, under "Connection Information". Or you
can fire up a console and enter `ip address`. Look for the part where it
says `de:ad:be:ef` - the MAC addresses that vm creates all start with that.

Now we return to the terminal on your host that you have been using so far. 
Create a host alias for guix so that vm can look it up:

    echo <the ip address from above> guix | sudo tee -a /etc/hosts
    
or you can add 

    VM_NET_GUEST=<still the same ip address>
    
to `.vmrc`.

Or use a completely different hostname and configure your internal
DNS server accordingly. You get the idea. Once again, on Guix you
can't simply add a line to `/etc/hosts` but the method with the ip in `.vmrc` 
will do the job just fine. By the way, `VM_NET_HOST` exists as well, in case
you want to use an interface other than the loopback for the monitor.
    
You can now do this:
 
    ping -c 3 guix
    
 to see whether your guest is reachable. Assuming that it is, the next step
 is to connect to it via ssh (you will be prompted for your password twice).
 
    ssh-keyscan guix >> .ssh/known_hosts
    ssh guido@guix mkdir .ssh
    scp .ssh/id_rsa.pub guido@guix:~/.ssh/authorized_keys

Now if you do:

    ssh guido@guix
    
it should log you in without prompting for a password. Brilliant!
The only thing that remains to do is grant yourself the right to 
suspend, power off, and shutdown the system, also without being asked for
credentials.
    
Since we have made the slightly masochistic choice to use Guix for our
little experiment, we will now have to reconfigure the whole system to
add one line to `/etc/sudoers`.

First, edit the system definition:

    sudo nano /etc/config.scm
    
Between the line

>    (use-service-modules cups desktop networking ssh xorg)
    
and

>    (operating-system
    
insert the following:

    (define etc-sudoers-config
      (plain-file "etc-sudoers-config"
                  "Defaults  timestamp_timeout=480
    root      ALL=(ALL) ALL
    %wheel    ALL=(ALL) ALL
    guido     ALL=(ALL) NOPASSWD:/run/current-system/profile/bin/loginctl"))

and after

>    (host-name "guix")

insert

      (sudoers-file etc-sudoers-config)

then press `ctrl-s` to save the changes and `ctrl-x` to exit the editor.

Now reconfigure the system to reflect the change and grab a cup of coffee.

    sudo guix package --search-paths -p "/root/.config/guix/current"
    sudo sh -c "guix pull; guix package -p; guix system reconfigure --allow-downgrades /etc/config.scm"
    
## What other commands are there?

Type `vm` to see a complete list, type `vm <command> --help` to see
a list of supported command line options (except for `vm sh`, see below). 
Some options will not be discussed in the following because 
they are self-explaining.

### vm start

Rather than just (try to) run the emulator in the foreground, `vm start` 
provides a complete startup procedure. It sends qemu to the background
and then checks whether the emulator and the guest os have
come up correctly. You can watch the process using the `--verbose` option.

Note that when you interrupt vm with `ctrl-c`, qemu - still being a 
subprocess - will receive the SIGINT signal as well and terminate.

The command exits when

* the guest is ready to use or
* something went wrong, either qemu or the guest os did not come up properly,
or the guest os is frozen.

Like with all vm commands (except for `sh`), the exit status is 0 if everything
works as expected, 1 otherwise.

You can start directly from a previously saved state, use `--loadvm <name>`
for this. Unlike `vm run`, `vm start` will detect if the snapshot contains 
the machine in a suspended state and wake it up.

### vm stop

The default behaviour of `vm stop` is to suspend the guest os, save
a snapshot, exit the emulator gracefully (use `vm kill` afterwards
if you want to make sure that it is really dead), and finally sync the file 
system the images are stored on to make sure what you just saved survives a
somewhat rough system restart. Unless you use other options you must
specify a name for the snapshot to be saved using `--vm-save`.

Suspending the virtual machine is practical because this way the guest os 
already expects to not be running for a while. When you resume from a 
snapshot taken from a machine in the running state you will notice that the 
system time will be wrong among potentially a lot of other problems. 

Vm will detect whether `systemctl` or `loginctrl` are present and call the 
first one found using `sudo`; it is your responsibility to make sure that the 
user you configured in `.vmrc` can use the respective command without getting a 
password prompt (see **Set up networking** above); vm will not hang when
you don't do this, but it obviously won't work either.

Please do not try to finagle other systems to simulate the presence of
`systemctl` or `loginctl` by creating a script that echoes things to 
the kernel, as often described on the net, or call other programs which
basically do the same, like `zzz`. You will able to send your guest
os to sleep alright, but there is **no chance** to wake it up again, or
at least get either the display or the network to reset which boils down
to the same, believe me, I've tried. 

If your system runs `chronyd`, like e.g. Alpine Linux, I have found it viable to 
use the `--nosuspend` option and after startup, issue 
`ssh <there> sudo rc-service chronyd restart` to correct the time lapse.
I've had less success with `ntpd` though (Guix again, but it has `loginctl`, 
suspending it works fine).

When `vm start` loads the image and wakes the virtual machine up, most systems
will then proceed to revive the network, breathe air into the display, and
get the new system time (which qemu will gladly provide). So this way, to not
have to boot the virtual machine at all but instead have it ready in a matter
of seconds actually works out of the box. Meaning, if against all expectations
you end up with a frozen guest, it makes sense to experiment.

If you want to power the machine off instead, for instance for the
purpose of having an image consistently reflecting all the changes you have
made in a way that survives crashes, use the `--poweroff` switch. 
You can also use `--reboot` in which case the machine will not be stopped. 
This is a bit counterintuitive but it seemed overkill to create a separate 
command just for this.

Use `vm cmd savevm <snapshot name>` to save the machine state while leaving 
the machine running. There is also `loadvm`, `delvm` and `info snapshots`.

### vm status

This causes vm to water your plants and feed your fish.

### vm archive

This provides a simple yet effective way of backing up your virtual machine.
If you issue `vm archive --create` it will

* merge the content - including memory snapshots - of the backing file into the 
base file, a process known as *committing*, 
* overwrite the old base file with a fresh, empty one,
* create a directory named `<machine name>-<timestamp>` which reflects
the modification date of the base file, thereby providing some sort of a
 versioning mechanism,
* and copy base and backing files to that directory.

For this to not lead to inconsistencies, the emulator must not be running;
vm will refuse to touch the base file if it is. Vm can compress both files, 
but by default it will not compress the base because that might be
a lenthy process. Plus, if you keep it in an uncompressed state you can
still run the archived machine just by copying the `.vmrc` from the parent
directory! 

After that you can call `vm archive` without parameters to quickly update
the archive by only copying the current version of the backing file. Vm 
expects the machine to be running for this purpose. Although not strictly
necessary, this way it can flush the guest's caches to disk, 
save a memory snapshot before copying the file, and it will also briefly
stop the emulator while it does that. Afterwards, it can delete the
no longer needed snapshot you created with `vm stop` from the archived version
and optionally compress it.

### vm sh

This opens a subshell of the one vm is called from. It also loads 
the basic functions and exports all the variables mentioned in `variables.txt`
before doing so.

When called from the command line it will drop you in an interactive shell (try

    set | grep ^VM_

to see all the variables that vm is using). Note that when called like
this, `vm sh` will simply eat any other options you may have provided, including
`--help`.

You can also use it as a shell replacement in your scripts - ideal for 
extending vm's functionality and further automate related tasks. In this case 
the rest of the command line will be captured in the
environment variable `VM_PARAMS`.

See the `example-script` in the main directory for, well, an example.

## What other configuration options are there?

`VM_QEMU_EXTRA` probably deserves to be mentioned. It can be used to pass 
extra arguments to qemu itself.

For a complete list of environment variables with explanations see 
`variables.txt` in the main directory.
Globally active options are stored in `lib/vmrc`, this file has comments too.

### Display options

You can set `VM_QEMU_VNC` to `[host]:<display number>` (this is what 
qemu understands, vm will just pass it through). So, if you
set the variable to `:2`, point your favourite vnc viewer to
`vnc://localhost:5902`.

You can also set `VM_QEMU_DISPLAY` to one of whichever display options qemu was
compiled with. In the case of `curses`, there are provisions (especially
`vm start` will not run) so that you don't end up rendering the 
very shell unusable that you use vm in - or the emulator for that matter.

## I have made some changes to vm that I find useful. What should I do?

Zip it. And send the zip file to <daniel.schlachta@hotmail.com>. 
Or if you like to make tarballs and patches, please
include the output of `git rev-parse HEAD` in your mail.

## What license is vm published under?

Except as represented in this agreement, all work product by Developer is provided ​“AS IS”. Other than as provided in this agreement, Developer makes no other warranties, express or implied, and hereby disclaims all implied warranties, including any warranty of merchantability and warranty of fitness for a particular purpose.

***You asked.***
