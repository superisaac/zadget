ALL=../zadget/zadget.swf
PLOT_SWF=swf/plot.swf
MEDIA_SWF=swf/media.swf
DOODLE_SWF=swf/doodle.swf

SOURCES=main.as Log.as $(shell find me/zadget -name '*.as')

CONFIG_ALL=-define=CONFIG::use_plot,true -define=CONFIG::use_media,true -define=CONFIG::use_doodle,true
CONFIG_PLOT=-define=CONFIG::use_plot,true -define=CONFIG::use_media,false -define=CONFIG::use_doodle,false
CONFIG_MEDIA=-define=CONFIG::use_plot,false -define=CONFIG::use_media,true -define=CONFIG::use_doodle,false
CONFIG_DOODLE=-define=CONFIG::use_plot,false -define=CONFIG::use_media,false -define=CONFIG::use_doodle,true

MXMLC_OPTIONS=-default-size=500,500

all: $(ALL)

$(ALL): $(SOURCES)
	mxmlc -output $@ main.as $(MXMLC_OPTIONS) $(CONFIG_ALL)

$(PLOT_SWF): $(SOURCES)
	mxmlc -output $@ main.as $(MXMLC_OPTIONS) $(CONFIG_PLOT)

$(MEDIA_SWF): $(SOURCES)
	mxmlc -output $@ main.as $(MXMLC_OPTIONS) $(CONFIG_MEDIA)

$(DOODLE_SWF): $(SOURCES)
	mxmlc -output $@ main.as $(MXMLC_OPTIONS) $(CONFIG_DOODLE)

mini_swf: $(PLOT_SWF) $(MEDIA_SWF) $(DOODLE_SWF)

clean:
	rm -Rf $(ALL) $(PLOT_SWF) $(MEDIA_SWF) $(DOODLE_SWF)