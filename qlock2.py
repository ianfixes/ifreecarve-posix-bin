#!/usr/bin/env python
###########################################################################
#    Copyright (C) 2009 by Ian Katz <ijk5@mit.edu> 
#
#    qlocktwo - ian's clone of Biegert & Funk's Qlocktwo in  TEXTMODE :)
#
#    Released under the WTFPL:
#
#
#               DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                       Version 2, December 2004
#    
#    Copyright (C) 2004 Sam Hocevar
#     14 rue de Plaisance, 75014 Paris, France
#    Everyone is permitted to copy and distribute verbatim or modified
#    copies of this license document, and changing it is allowed as long
#    as the name is changed.
#    
#               DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#      TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#    
#     0. You just DO WHAT THE FUCK YOU WANT TO.
#    
###########################################################################


import sys
import time
import urwid.curses_display
import urwid

class Qlock(object):

    class ExitFromUser(Exception):
        pass

    class Light(object):
        def __init__(self, text, ignored):
            def reformat(s):
                ret = ""
                for c in s.upper():
                    ret += c + " "
                return ret

            rt = reformat(text)
            self.txtlen = len(rt)
            self.widget = urwid.Text(rt)

            self.process_arg(ignored)

        def process_arg(self, ignored):
            pass

        def get_widget(self):
            return self.widget

        def is_lit(self, thetime):
            return false

        def on(self):
            return self.is_lit(time.localtime())

        def get_txtlen(self):
            return self.txtlen

    class ConstLight(Light):
        def process_arg(self, state):
            self.state = state

        def is_lit(self, thetime):
            return self.state

    class MinLight(Light):
        def process_arg(self, minute_tuples):
            self.set_ranges(minute_tuples)

        def set_ranges(self, minute_tuples):
            self.ranges = minute_tuples
        
        def is_lit(self, thetime):
            m = thetime.tm_min
            return any(map(lambda (lo, hi): lo <= m < hi, self.ranges))

    class HourLight(Light):
        def process_arg(self, hour):
            self.set_hour(hour)

        def set_hour(self, hour):
            self.hour = hour

        def is_lit(self, thetime):
            h = thetime.tm_hour % 12
            m = thetime.tm_min
            ph = (h + 1) % 12

            return (h == (self.hour % 12) and (0 <= m < 40)
                    or
                    ph == (self.hour % 12) and (40 <= m < 60))
        
        

    def __init__(self):

        def prepare(acc, elements, prefix, aclass):

            for k, v in elements.iteritems():
                c = aclass(k, v)
                acc[prefix + k] = c
            
            return acc
                                       

        hours = {
            "one"     : 1,
            "two"     : 2,
            "three"   : 3,
            "four"    : 4,
            "five"    : 5,
            "six"     : 6,
            "seven"   : 7,
            "eight"   : 8,
            "nine"    : 9,
            "ten"     : 10,
            "eleven"  : 11,
            "twelve"  : 0,
            }

        minutes = {
            "oclock"       : [(0, 5)],
            "five"         : [(5, 10), (25, 30), (55, 60),],
            "ten"          : [(10, 15), (50, 55),],
            "quarter"      : [(15, 20), (45, 50),],
            "twenty"       : [(20, 30), (40, 45),],
            "half"         : [(30, 35)],
            "thirtyfive"   : [(35, 40)],
            }

        words = {
            "of"      : [(40, 60)],
            "past"    : [(5, 40)],
            }

        filler = {
            "its" : True,
            "y"   : False,
            "g"   : False,
            "x"   : False,
            "wq"  : False,
            "xi"  : False,
            "u"   : False,
            "lf"  : False,
            }

        self.possible_colors = {
            "red"   : "red",
            "green" : "green",
            "blue"  : "blue",
            "gray"  : "gray",
            "grey"  : "gray",
            }

        elements = {}
        elements = prepare(elements, hours, "hour_", Qlock.HourLight)
        elements = prepare(elements, minutes, "min_", Qlock.MinLight)
        elements = prepare(elements, words, "word_", Qlock.MinLight)
        elements = prepare(elements, filler, "fill_", Qlock.ConstLight)
        self.elements = elements


        self.MakeScreen()


    def MakeScreen(self):

        def blank(n):
            blank_txt = urwid.Text("")
            return ('fixed', n, 
                    urwid.AttrWrap(blank_txt, self.StyleForState(False)))

        def emptyRow():
            return urwid.Columns([blank(29)], dividechars=0, focus_column=0)

        def makeRow(items):
            
            def wrapItem(it):
                e = self.elements[it]
                w = urwid.AttrWrap(e.get_widget(), self.StyleForState(e.on()))
                ret = ('fixed', e.get_txtlen(), w)

                return ret
            
            wrapped_items = map(wrapItem, items)
            padded_items = [blank(4)] + wrapped_items + [blank(3)]

            return [urwid.Columns(padded_items, dividechars=0, focus_column=0)]



        rows = []
        rows += [emptyRow()]
        rows += [emptyRow()]
        rows += makeRow(["fill_its", "fill_y", "min_quarter"])
        rows += makeRow(["min_twenty", "min_five", "fill_g"])
        rows += makeRow(["min_thirtyfive", "fill_x"])
        rows += makeRow(["min_half", "min_ten", "fill_wq", "word_of"])
        rows += makeRow(["word_past", "fill_xi", "hour_seven"])
        rows += makeRow(["hour_one", "hour_two", "hour_three"])
        rows += makeRow(["hour_four", "hour_five", "hour_six"])
        rows += makeRow(["hour_eight", "hour_eleven"])
        rows += makeRow(["hour_nine", "fill_u", "hour_twelve"])
        rows += makeRow(["hour_ten", "fill_lf", "min_oclock"])
        rows += [emptyRow()]
        rows += [emptyRow()]

        lw = urwid.SimpleListWalker(rows)
        lb = urwid.ListBox(lw)

        self.top = urwid.Frame(lb)

        return


    def StyleForState(self, enabled):
        try: 
            color = self.possible_colors[sys.argv[1].lower()]
        except:
            color = 'red'

        if enabled:
            return "on " + color
        else:
            return "off " + color


    def main(self):
        self.ui = urwid.curses_display.Screen()
        self.ui.register_palette([
            ('on red',       'white',      'dark red',   'bold'),
            ('off red',      'black',      'dark red',   'bold'),
            ('on green',     'white',      'dark green',   'bold'),
            ('off green',    'black',      'dark green',   'bold'),
            ('on blue',      'white',      'dark blue',   'bold'),
            ('off blue',     'black',      'dark blue',   'bold'),
            ('on gray',      'white',      'black',   'bold'),
            ('off gray',     'dark gray',  'black',   'bold'),
                ])
        self.ui.run_wrapper(self.run)

    def run(self):
        self.screen_size = self.ui.get_cols_rows()
        
        while True:
            self.draw_screen()

            try:
                self.HandleKeys()
            except Qlock.ExitFromUser:
                break


    def HandleKeys(self):

        keys = self.ui.get_input()
        
        self.MakeScreen()
                
        #precedence above all others
        if "q" in keys:
            raise Qlock.ExitFromUser()
        
        #handle other globals
        for k in keys:
            if k == "window resize":
                self.screen_size = self.ui.get_cols_rows()
            elif k == "crtl l":
                self.ui.s.clear() # refresh screen
                self.MakeScreen()
            else:
                #self.keypress(k) #non-globals
                pass


    def draw_screen(self):   
        canvas = self.top.render(self.screen_size, focus=True)
        self.ui.draw_screen(self.screen_size, canvas)



myClock = Qlock()
myClock.main()
            
