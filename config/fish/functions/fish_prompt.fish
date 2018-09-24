
function fish_prompt
    # these pick up the status of the last command and set things red or green
    and set retc green
    or set retc red

    # these try to set the terminal to something sane
    tty | string match -q -r tty
    and set tty tty
    or set tty pts
    set tty pts # just force it, OSX is dumb.

    set_color $retc
    if [ $tty = tty ]
        echo -n '/ '
    else
        echo -n '┌ '
    end

    set_color -o green
    if test "$USER" = root -o "$USER" = toor
        set_color -o red
    else
        set_color -o green
    end

    echo -n $USER
    #set_color -o white
    echo -n @
    if [ -z "$SSH_CLIENT" ]
        set_color -o yellow
    else
        set_color -o cyan
    end

    echo -n (prompt_hostname)
    set_color -o white
    echo -n :
    set_color -o cyan
    #echo -n (prompt_pwd)
    echo -n (pwd|sed "s=$HOME=~=")
    set_color -o green

    # # display the time
    # set_color normal
    # set_color $retc
    # if [ $tty = tty ]
    #     echo -n '-'
    # else
    #     echo -n '─'
    # end
    #
    # set_color -o green
    # echo -n '['
    # set_color normal
    # set_color $retc
    # echo -n (date +%X)
    # set_color -o green
    # echo -n ]

    # display battery
    if type -q acpi
        if [ (acpi -a 2> /dev/null | string match -r off) ]
            echo -n '─['
            set_color -o red
            echo -n (acpi -b|cut -d' ' -f 4-)
            set_color -o green
            echo -n ']'
        end
    end

    # print background jobs
    echo
    set_color normal
    for job in (jobs)
        set_color $retc
        if [ $tty = tty ]
            echo -n '+ '
        else
            echo -n '├ '
        end
        set_color brown
        echo $job
    end

    # display actual prompt
    set_color normal
    set_color $retc
    if [ $tty = tty ]
        echo -n "'->"
    else
        echo -n '└>'
    end
    set_color -o cyan
    echo -n '$ '
    set_color normal
end
