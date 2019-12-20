dlr_sources = [
   'Application.vala',
   'ui/MainWindow.vala',
   'stations/DLF.vala',
   'stations/Nova.vala',
   'stations/Kultur.vala',
   'stations/EpisodeQuery.vala',
   'stations/playable/A_Station.vala',
   'stations/E_StationNames.vala',
   'stations/playable/I_Playable.vala',
   'player/StreamPlayer.vala',
   'stations/digests/Episode.vala',
   'stations/digests/Broadcast.vala',
   'stations/digests/LiveRadioInfo.vala',
   'stations/digests/BroadcastParser.vala',
   'stations/digests/EpisodeParser.vala',
   'utils/Deserializable.vala',
   'utils/SchemaIO.vala',
   'player/MediaKeys.vala',
   'player/GnomeMediaKeys.vala',
   'player/SoundIndicator.vala',
   'player/SoundIndicatorPlayer.vala',
   'player/SoundIndicatorRoot.vala',
   # 'ui/views/I_TreeView.vala',
   # 'ui/views/EpisodesTreeView.vala',
]

dlr_test = [
   'tests/unit_test.vala',
]

# tests = executable('tests', dlr_test, dlr_sources ,dependencies: dlr_dependencies,)
# test(
#    'Unit Tests',
#    tests
# )

dlr_sources += gnome.compile_resources(
       'dlr-resources',
       'ui/gresource.xml',
       source_dir: 'ui'
)

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
   meson.project_name(),
   ['main.vala'],
   dlr_sources,
   dependencies: dlr_dependencies,
   install: true,
   export_dynamic: true,
   gui_app: true,
)
