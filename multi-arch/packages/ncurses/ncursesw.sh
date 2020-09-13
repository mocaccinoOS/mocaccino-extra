#!/bin/sh
pkgdir=/ncurses

# Install basic terms in /etc/terminfo
for i in ansi console dumb linux rxvt screen sun vt52 vt100 vt102 \
        vt200 vt220 xterm xterm-color xterm-xfree86 xterm-256color \
        alacritty tmux tmux-256color terminator 'terminology*' \
        vte vte-256color gnome gnome-256color kitty konsole konsole-256color \
        konsole-linux putty putty-256color rxvt-256color 'st-*' \
        screen-256color; do
    termfiles=$(find "$pkgdir"/usr/share/terminfo/ -name "$i" 2>/dev/null) || true

    [ -z "$termfiles" ] && continue

    for termfile in $termfiles; do
        basedir=$(basename "$(dirname "$termfile")")
        install -d "$pkgdir"/etc/terminfo/$basedir
        mv "$termfile" "$pkgdir"/etc/terminfo/$basedir/
        ln -s "../../../../etc/terminfo/$basedir/${termfile##*/}" \
            "$pkgdir/usr/share/terminfo/$basedir/${termfile##*/}"
    done
done

## force link against *w.so
for lib in ncurses ncurses++ form panel menu; do
    echo "INPUT(-l${lib}w)" > /ncurses/usr/lib/lib$lib.so
    ln -s ${lib}w.pc /ncurses/usr/lib/pkgconfig/$lib.pc
done
# link curses -> ncurses
echo "INPUT(-lncursesw)" > /ncurses/usr/lib/libcursesw.so
ln -s libncurses.so /ncurses/usr/lib/libcurses.so

cp -rfv /ncurses/* /