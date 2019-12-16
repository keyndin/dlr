# project name and programming language
project('com.github.keyndin.dlr', 'vala', 'c')

gnome = import('gnome')

dlr_sources = [
   'src/ui/MainWindow.vala',
   'src/stations/DLF.vala',
   'src/stations/Nova.vala',
   'src/stations/Kultur.vala',
   'src/stations/EpisodeQuery.vala',
   'src/stations/playable/A_Station.vala',
   'src/stations/E_StationNames.vala',
   'src/stations/playable/I_Playable.vala',
   'src/player/StreamPlayer.vala',
   'src/stations/digests/Episode.vala',
   'src/stations/digests/Broadcast.vala',
   'src/stations/digests/LiveRadioInfo.vala',
   'src/stations/digests/BroadcastParser.vala',
   'src/stations/digests/EpisodeParser.vala',
   'src/utils/Deserializable.vala',
   'src/utils/SchemaIO.vala',
   'src/player/MediaKeys.vala',
]

dlr_dependencies = [
   dependency('gtk+-3.0'),
   dependency('gstreamer-1.0'),
   dependency('libxml-2.0'),
   dependency('libsoup-2.4'),
   dependency('gio-2.0')
]

dlr_sources += gnome.compile_resources(
       'dlr-resources',
       'src/ui/gresource.xml',
       source_dir: 'src/ui'
)

dlr_test = [
   'src/tests/unit_test.vala',
]
tests = executable('tests', dlr_test, dlr_sources ,dependencies: dlr_dependencies,)
test(
   'Unit Tests',
   tests
)

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
   meson.project_name(),
   ['src/main.vala'],
   dlr_sources,
   dependencies: dlr_dependencies,
   install: true,
   export_dynamic: true,
   gui_app: true,
)

#Install our .desktop file in order for the Applications Menu to see it
install_data(
   join_paths('data', meson.project_name() + '.desktop'),
   install_dir: join_paths(get_option('datadir'), 'applications')
)

#Install our .appdata.xml file for AppCenter to see it
install_data(
   join_paths('data', meson.project_name() + '.appdata.xml'),
   install_dir: join_paths(get_option('datadir'), 'metainfo')
)

subdir('data')