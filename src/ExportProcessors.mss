function ProcessScore () {
    //$module(ExportProcessors.mss)
    // processors are a bit like a workflow manager -- they orchestrate the
    // generators, which in turn use the converters to convert specific values from sibelius
    // to MEI.
    mei = CreateElement('mei');
    SetDocumentRoot(mei);

    AddAttribute(mei, 'xmlns:xlink', 'http://www.w3.org/1999/xlink');
    AddAttribute(mei, 'xmlns', 'http://www.music-encoding.org/ns/mei');
    AddAttribute(mei, 'meiversion', MeiVersion);

    header = GenerateMEIHeader();
    AddChild(mei, header);

    music = GenerateMEIMusic();
    AddChild(mei, music);

}  //$end


function ProcessBlankPageContent (bobjs, parent) {
    // bobjs: SparseArray() of objects that are attached to the preceding or
    //   following blank pages of a specific Bar.
    // parent: MEI element that <pb> and <div> elements containing all the
    //   elements of a blank page should be attached to.

    if (null = bobjs)
    {
        return '';
    }

    currentPnum = -1;
    div = null;

    for each bobj in bobjs
    {
        pnum = (bobj.ParentBar.OnNthPage + bobj.OnNthBlankPage) + 1;
        if (pnum > currentPnum or null = div)
        {
            currentPnum = pnum;
            pb = CreateElement('pb');
            AddAttribute(pb, 'n', pnum);
            AddChild(parent, pb);
            div = CreateElement('div');
            AddChild(parent, div);
        }
        element = HandleStyle(TextHandlers, bobj);
        if (null != element)
        {
            AddChild(div, element);
        }
    }
} //$end


function ProcessEndingLines (bar) {
    //$module(ExportProcessors.mss)
    lineResolver = Self._property:LineEndResolver;
    for voiceNumber = 1 to 5
    {
        endingLines = lineResolver[LayerHash(bar, voiceNumber)];
        if (endingLines != null)
        {
            for each line in endingLines
            {
                meiLine = line._property:mobj;
                endidSearchStrategy = meiLine.attrs['endid'];
                if ('' = endidSearchStrategy)
                {
                    end_obj = null;
                }
                else
                {
                    end_obj = GetNoteObjectAtPosition(line, endidSearchStrategy, 'EndPosition');
                }

                if (end_obj = null)
                {
                    meiLine.attrs.endid = ' ';
                }
                else
                {
                    AddAttribute(meiLine, 'endid', '#' & end_obj._id);
                }
            }
        }
    }
}  //$end


function ProcessBarObjects (bar) {
    // Processes all BarObjects in bar, except for NoteRest, BarRest, Tuplet and
    // Clef.
    for each bobj in bar
    {
        switch (bobj.Type)
        {
            case('GuitarFrame')
            {
                GenerateChordSymbol(bobj);
            }
            case('Slur')
            {
                HandleStyle(LineHandlers, bobj);
            }
            case('CrescendoLine')
            {
                HandleStyle(LineHandlers, bobj);
            }
            case('DiminuendoLine')
            {
                HandleStyle(LineHandlers, bobj);
            }
            case('OctavaLine')
            {
                HandleStyle(LineHandlers, bobj);
            }
            case('GlissandoLine')
            {
                HandleStyle(LineHandlers, bobj);
            }
            case('Trill')
            {
                HandleStyle(LineHandlers, bobj);
            }
            case('ArpeggioLine')
            {
                GenerateArpeggio(bobj);
            }
            case('Line')
            {
                HandleStyle(LineHandlers, bobj);
            }
            case('Text')
            {
                if (bobj.Text != '')
                {
                    HandleStyle(TextHandlers, bobj);
                }
            }
            case('SymbolItem')
            {
                HandleSymbol(bobj);
            }
        }
    }
} //$end
