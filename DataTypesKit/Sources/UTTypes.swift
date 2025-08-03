//
//  UTTypes.swift
//  DataTypesKit
//
//  Created by Lakhan Lothiyi on 14/01/2025.
//

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
public extension DataType {
		/**
				A generic base type for most things (files, directories.)
			
				**UTI:** public.item
			*/
		static var item: DataType { .init(from: .item) }

		/**
				A base type for anything containing user-viewable document content
				(documents, pasteboard data, and document packages.)
			
				Types describing files or packages must also conform to `UTType.data` or
				`UTType.package` in order for the system to bind documents to them.
			
				**UTI:** public.content
			*/
		static var content: DataType { .init(from: .content) }

		/**
				A base type for content formats supporting mixed embedded content
				(i.e., compound documents).
			
				**UTI:** public.composite-content
			
				**conforms to:** public.content
			*/
		static var compositeContent: DataType { .init(from: .compositeContent) }

		/**
				A data item mountable as a volume
			
				**UTI:** public.disk-image
			*/
		static var diskImage: DataType { .init(from: .diskImage) }

		/**
				A base type for any sort of simple byte stream, including files and
				in-memory data.
			
				**UTI:** public.data
			
				**conforms to:** public.item
			*/
		static var data: DataType { .init(from: .data) }

		/**
				A file system directory (includes packages _and_ folders.)
			
				**UTI:** public.directory
			
				**conforms to:** public.item
			*/
		static var directory: DataType { .init(from: .directory) }

		/**
				Symbolic link and alias file types conform to this type.
			
				**UTI:** com.apple.resolvable
			*/
		static var resolvable: DataType { .init(from: .resolvable) }

		/**
				A symbolic link.
			
				**UTI:** public.symlink
			
				**conforms to:** public.item, com.apple.resolvable
			*/
		static var symbolicLink: DataType { .init(from: .symbolicLink) }

		/**
				An executable item.
			
				**UTI:** public.executable
			
				**conforms to:** public.item
			*/
		static var executable: DataType { .init(from: .executable) }

		/**
				A volume mount point (resolvable, resolves to the root directory of a
				volume.)
			
				**UTI:** com.apple.mount-point
			
				**conforms to:** public.item, com.apple.resolvable
			*/
		static var mountPoint: DataType { .init(from: .mountPoint) }

		/**
				A fully-formed alias file.
			
				**UTI:** com.apple.alias-file
			
				**conforms to:** public.data, com.apple.resolvable
			*/
		static var aliasFile: DataType { .init(from: .aliasFile) }

		/**
				A URL bookmark.
			
				**UTI:** com.apple.bookmark
			
				**conforms to:** public.data, com.apple.resolvable
			*/
		static var urlBookmarkData: DataType { .init(from: .urlBookmarkData) }

		/**
				Any URL.
			
				**UTI:** public.url
			
				**conforms to:** public.data
			*/
		static var url: DataType { .init(from: .url) }

		/**
				A URL with the scheme `"file:"`.
			
				**UTI:** public.file-url
			
				**conforms to:** public.url
			*/
		static var fileURL: DataType { .init(from: .fileURL) }

		/**
				The base type for all text-encoded data, including text with markup
				(HTML, RTF, etc.).
			
				**UTI:** public.text
			
				**conforms to:** public.data, public.content
			*/
		static var text: DataType { .init(from: .text) }

		/**
				Text with no markup and an unspecified encoding.
			
				**UTI:** public.plain-text
			
				**conforms to:** public.text
			*/
		static var plainText: DataType { .init(from: .plainText) }

		/**
				Plain text encoded as UTF-8.
			
				**UTI:** public.utf8-plain-text
			
				**conforms to:** public.plain-text
			*/
		static var utf8PlainText: DataType { .init(from: .utf8PlainText) }

		/**
				Plain text encoded as UTF-16 with a BOM, or if a BOM is not present,
				using "external representation" byte order (big-endian).
			
				**UTI:** public.utf16-external-plain-text
			
				**conforms to:** public.plain-text
			*/
		static var utf16ExternalPlainText: DataType { .init(from: .utf16ExternalPlainText) }

		/**
				Plain text encoded as UTF-16, in native byte order, with an optional
				BOM.
			
				**UTI:** public.utf16-plain-text
			
				**conforms to:** public.plain-text
			*/
		static var utf16PlainText: DataType { .init(from: .utf16PlainText) }

		/**
				Text containing delimited values.
			
				**UTI:** public.delimited-values-text
			
				**conforms to:** public.text
			*/
		static var delimitedText: DataType { .init(from: .delimitedText) }

		/**
				Text containing comma-separated values (.csv).
			
				**UTI:** public.comma-separated-values-text
			
				**conforms to:** public.delimited-values-text
			*/
		static var commaSeparatedText: DataType { .init(from: .commaSeparatedText) }

		/**
				Text containing tab-separated values.
			
				**UTI:** public.tab-separated-values-text
			
				**conforms to:** public.delimited-values-text
			*/
		static var tabSeparatedText: DataType { .init(from: .tabSeparatedText) }

		/**
				UTF-8 encoded text containing tab-separated values.
			
				**UTI:** public.utf8-tab-separated-values-text
			
				**conforms to:** public.tab-separated-values-text, public.utf8-plain-text
			*/
		static var utf8TabSeparatedText: DataType { .init(from: .utf8TabSeparatedText) }

		/**
				Rich Text Format data.
			
				**UTI:** public.rtf
			
				**conforms to:** public.text
			*/
		static var rtf: DataType { .init(from: .rtf) }

		/**
				Any version of HTML.
			
				**UTI:** public.html
			
				**conforms to:** public.text
			*/
		static var html: DataType { .init(from: .html) }

		/**
				Generic XML.
			
				**UTI:** public.xml
			
				**conforms to:** public.text
			*/
		static var xml: DataType { .init(from: .xml) }

		/**
				Yet Another Markup Language.
			
				**UTI:** public.yaml
			
				**conforms to:** public.text
			*/
		static var yaml: DataType { .init(from: .yaml) }

		/**
				Cascading Style Sheets (CSS)
			
				**UTI:** public.css
			
				**conforms to:** public.text
			*/
		@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, *)
		static var css: DataType { .init(from: .css) }

		/**
				Abstract type for source code of any language.
			
				**UTI:** public.source-code
			
				**conforms to:** public.plain-text
			*/
		static var sourceCode: DataType { .init(from: .sourceCode) }

		/**
				Assembly language source (.s)
			
				**UTI:** public.assembly-source
			
				**conforms to:** public.source-code
			*/
		static var assemblyLanguageSource: DataType { .init(from: .assemblyLanguageSource) }

		/**
				C source code (.c)
			
				**UTI:** public.c-source
			
				**conforms to:** public.source-code
			*/
		static var cSource: DataType { .init(from: .cSource) }

		/**
				Objective-C source code (.m)
			
				**UTI:** public.objective-c-source
			
				**conforms to:** public.source-code
			*/
		static var objectiveCSource: DataType { .init(from: .objectiveCSource) }

		/**
				Swift source code (.swift)
			
				**UTI:** public.swift-source
			
				**conforms to:** public.source-code
			*/
		static var swiftSource: DataType { .init(from: .swiftSource) }

		/**
				C++ source code (.cp, etc.)
			
				**UTI:** public.c-plus-plus-source
			
				**conforms to:** public.source-code
			*/
		static var cPlusPlusSource: DataType { .init(from: .cPlusPlusSource) }

		/**
				Objective-C++ source code.
			
				**UTI:** public.objective-c-plus-plus-source
			
				**conforms to:** public.source-code
			*/
		static var objectiveCPlusPlusSource: DataType { .init(from: .objectiveCPlusPlusSource) }

		/**
				A C header.
			
				**UTI:** public.c-header
			
				**conforms to:** public.source-code
			*/
		static var cHeader: DataType { .init(from: .cHeader) }

		/**
				A C++ header.
			
				**UTI:** public.c-plus-plus-header
			
				**conforms to:** public.source-code
			*/
		static var cPlusPlusHeader: DataType { .init(from: .cPlusPlusHeader) }

		/**
				A base type for any scripting language source.
			
				**UTI:** public.script
			
				**conforms to:** public.source-code
			*/
		static var script: DataType { .init(from: .script) }

		/**
				An AppleScript text-based script (.applescript).
			
				**UTI:** com.apple.applescript.text
			
				**conforms to:** public.script
			*/
		static var appleScript: DataType { .init(from: .appleScript) }

		/**
				An Open Scripting Architecture binary script (.scpt).
			
				**UTI:** com.apple.applescript.script
			
				**conforms to:** public.data, public.script
			*/
		static var osaScript: DataType { .init(from: .osaScript) }

		/**
				An Open Scripting Architecture script bundle (.scptd).
			
				**UTI:** com.apple.applescript.script-bundle
			
				**conforms to:** com.apple.bundle, com.apple.package, public.script
			*/
		static var osaScriptBundle: DataType { .init(from: .osaScriptBundle) }

		/**
				JavaScript source code
			
				**UTI:** com.netscape.javascript-source
			
				**conforms to:** public.source-code, public.executable
			*/
		static var javaScript: DataType { .init(from: .javaScript) }

		/**
				The base type for shell scripts.
			
				**UTI:** public.shell-script
			
				**conforms to:** public.script
			*/
		static var shellScript: DataType { .init(from: .shellScript) }

		/**
				A Perl script.
			
				**UTI:** public.perl-script
			
				**conforms to:** public.shell-script
			*/
		static var perlScript: DataType { .init(from: .perlScript) }

		/**
				A Python script.
			
				**UTI:** public.python-script
			
				**conforms to:** public.shell-script
			*/
		static var pythonScript: DataType { .init(from: .pythonScript) }

		/**
				A Ruby script.
			
				**UTI:** public.ruby-script
			
				**conforms to:** public.shell-script
			*/
		static var rubyScript: DataType { .init(from: .rubyScript) }

		/**
				A PHP script.
			
				**UTI:** public.php-script
			
				**conforms to:** public.shell-script
			*/
		static var phpScript: DataType { .init(from: .phpScript) }

		/**
				A makefile.
			
				**UTI:** public.make-source
			
				**conforms to:** public.script
			*/
		@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
		static var makefile: DataType { .init(from: .makefile) }

		/**
				JavaScript object notation (JSON) data
			
				**UTI:** public.json
			
				**conforms to:** public.text
			
				- Note: JSON almost (but doesn't quite) conforms to
					com.netscape.javascript-source.
			*/
		static var json: DataType { .init(from: .json) }

		/**
				A base type for property lists.
			
				**UTI:** com.apple.property-list
			
				**conforms to:** public.data
			*/
		static var propertyList: DataType { .init(from: .propertyList) }

		/**
				An XML property list.
			
				**UTI:** com.apple.xml-property-list
			
				**conforms to:** public.xml, com.apple.property-list
			*/
		static var xmlPropertyList: DataType { .init(from: .xmlPropertyList) }

		/**
				A binary property list.
			
				**UTI:** com.apple.binary-property-list
			
				**conforms to:** com.apple.property-list
			*/
		static var binaryPropertyList: DataType { .init(from: .binaryPropertyList) }

		/**
				An Adobe PDF document.
			
				**UTI:** com.adobe.pdf
			
				**conforms to:** public.data, public.composite-content
			*/
		static var pdf: DataType { .init(from: .pdf) }

		/**
				A Rich Text Format Directory document (RTF with content embedding
				in its on-disk format.)
			
				**UTI:** com.apple.rtfd
			
				**conforms to:** com.apple.package, public.composite-content
			*/
		static var rtfd: DataType { .init(from: .rtfd) }

		/**
				A flattened RTFD document (formatted for the pasteboard.)
			
				**UTI:** com.apple.flat-rtfd
			
				**conforms to:** public.data, public.composite-content
			*/
		static var flatRTFD: DataType { .init(from: .flatRTFD) }

		/**
				The WebKit webarchive format.
			
				**UTI:** com.apple.webarchive
			
				**conforms to:** public.data, public.composite-content
			*/
		static var webArchive: DataType { .init(from: .webArchive) }

		/**
				A base type for abstract image data.
			
				**UTI:** public.image
			
				**conforms to:** public.data, public.content
			*/
		static var image: DataType { .init(from: .image) }

		/**
				A JPEG image.
			
				**UTI:** public.jpeg
			
				**conforms to:** public.image
			*/
		static var jpeg: DataType { .init(from: .jpeg) }

		/**
				A TIFF image.
			
				**UTI:** public.tiff
			
				**conforms to:** public.image
			*/
		static var tiff: DataType { .init(from: .tiff) }

		/**
				A GIF image.
			
				**UTI:** com.compuserve.gif
			
				**conforms to:** public.image
			*/
		static var gif: DataType { .init(from: .gif) }

		/**
				A PNG image.
			
				**UTI:** public.png
			
				**conforms to:** public.image
			*/
		static var png: DataType { .init(from: .png) }

		/**
				Apple icon data
			
				**UTI:** com.apple.icns
			
				**conforms to:** public.image
			*/
		static var icns: DataType { .init(from: .icns) }

		/**
				A Windows bitmap.
			
				**UTI:** com.microsoft.bmp
			
				**conforms to:** public.image
			*/
		static var bmp: DataType { .init(from: .bmp) }

		/**
				Windows icon data
			
				**UTI:** com.microsoft.ico
			
				**conforms to:** public.image
			*/
		static var ico: DataType { .init(from: .ico) }

		/**
				A base type for raw image data (.raw).
			
				**UTI:** public.camera-raw-image
			
				**conforms to:** public.image
			*/
		static var rawImage: DataType { .init(from: .rawImage) }

		/**
				A Scalable Vector Graphics image.
			
				**UTI:** public.svg-image
			
				**conforms to:** public.image
			*/
		static var svg: DataType { .init(from: .svg) }

		/**
				A Live Photo.
			
				**UTI:** com.apple.live-photo
			*/
		static var livePhoto: DataType { .init(from: .livePhoto) }

		/**
				A High Efficiency Image File Format image.
			
				**UTI:** public.heif
			
				**conforms to:** public.heif-standard
			*/
		static var heif: DataType { .init(from: .heif) }

		/**
				A High Efficiency Image Coding image.
			
				**UTI:** public.heic
			
				**conforms to:** public.heif-standard
			*/
		static var heic: DataType { .init(from: .heic) }

		/**
				A High Efficiency Image Coding Image Sequence.
			
				**UTI:** public.heics
			
				**conforms to:** public.heif-standard
			*/
		@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, *)
		static var heics: DataType { .init(from: .heics) }

		/**
				The WebP image format.
			
				**UTI:** org.webmproject.webp
			
				**conforms to:** public.image
			*/
		static var webP: DataType { .init(from: .webP) }

		/**
				An EXR image.
			
				**UTI:** com.ilm.openexr-image
			
				**conforms to:** public.image
			*/
		@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, *)
		static var exr: DataType { .init(from: .exr) }

		/**
				An Adobe DNG (digital negative) image.
			
				**UTI:** com.adobe.raw-image
			
				**conforms to:** public.image
			*/
		@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, *)
		static var dng: DataType { .init(from: .dng) }

		/**
				A base type for 3D content.
			
				**UTI:** public.3d-content
			
				**conforms to:** public.content
			*/
		static var threeDContent: DataType { .init(from: .threeDContent) }

		/**
				Universal Scene Description content.
			
				**UTI:** com.pixar.universal-scene-description
			
				**conforms to:** public.3d-content, public.data
			*/
		static var usd: DataType { .init(from: .usd) }

		/**
				Universal Scene Description Package content.
			
				**UTI:** com.pixar.universal-scene-description-mobile
			
				**conforms to:** public.3d-content, public.data
			*/
		static var usdz: DataType { .init(from: .usdz) }

		/**
				A Reality File.
			
				**UTI:** com.apple.reality
			
				**conforms to:** public.data
			*/
		static var realityFile: DataType { .init(from: .realityFile) }

		/**
				A SceneKit serialized scene.
			
				**UTI:** com.apple.scenekit.scene
			
				**conforms to:** public.3d-content, public.data
			*/
		static var sceneKitScene: DataType { .init(from: .sceneKitScene) }

		/**
				An AR reference object.
			
				**UTI:** com.apple.arobject
			
				**conforms to:** public.data
			*/
		static var arReferenceObject: DataType { .init(from: .arReferenceObject) }

		/**
				Any audio and/or video content.
			
				**UTI:** public.audiovisual-content
			
				**conforms to:** public.data, public.content
			*/
		static var audiovisualContent: DataType { .init(from: .audiovisualContent) }

		/**
				A media format which may contain both video and audio.
			
				This type corresponds to what users would label a "movie".
			
				**UTI:** public.movie
			
				**conforms to:** public.audiovisual-content
			*/
		static var movie: DataType { .init(from: .movie) }

		/**
				Pure video data with no audio data.
			
				**UTI:** public.video
			
				**conforms to:** public.movie
			*/
		static var video: DataType { .init(from: .video) }

		/**
				Pure audio data with no video data.
			
				**UTI:** public.audio
			
				**conforms to:** public.audiovisual-content
			*/
		static var audio: DataType { .init(from: .audio) }

		/**
				A QuickTime movie.
			
				**UTI:** com.apple.quicktime-movie
			
				**conforms to:** public.movie
			*/
		static var quickTimeMovie: DataType { .init(from: .quickTimeMovie) }

		/**
				An MPEG-1 or MPEG-2 movie.
			
				**UTI:** public.mpeg
			
				**conforms to:** public.movie
			*/
		static var mpeg: DataType { .init(from: .mpeg) }

		/**
				An MPEG-2 video.
			
				**UTI:** public.mpeg-2-video
			
				**conforms to:** public.video
			*/
		static var mpeg2Video: DataType { .init(from: .mpeg2Video) }

		/**
				The MPEG-2 Transport Stream movie format.
			
				**UTI:** public.mpeg-2-transport-stream
			
				**conforms to:** public.movie
			*/
		static var mpeg2TransportStream: DataType { .init(from: .mpeg2TransportStream) }

		/**
				MP3 audio.
			
				**UTI:** public.mp3
			
				**conforms to:** public.audio
			*/
		static var mp3: DataType { .init(from: .mp3) }

		/**
				MPEG-4 movie
			
				**UTI:** public.mpeg-4
			
				**conforms to:** public.movie
			*/
		static var mpeg4Movie: DataType { .init(from: .mpeg4Movie) }

		/**
				An MPEG-4 audio layer file.
			
				**UTI:** public.mpeg-4-audio
			
				**conforms to:** public.mpeg-4, public.audio
			*/
		static var mpeg4Audio: DataType { .init(from: .mpeg4Audio) }

		/**
				The Apple protected MPEG4 format (.m4p, iTunes music store format.)
			
				**UTI:** com.apple.protected-mpeg-4-audio
			
				**conforms to:** public.audio
			*/
		static var appleProtectedMPEG4Audio: DataType { .init(from: .appleProtectedMPEG4Audio) }

		/**
				An Apple protected MPEG-4 movie.
			
				**UTI:** com.apple.protected-mpeg-4-video
			
				**conforms to:** com.apple.m4v-video
			*/
		static var appleProtectedMPEG4Video: DataType { .init(from: .appleProtectedMPEG4Video) }

		/**
				The AVI movie format.
			
				**UTI:** public.avi
			
				**conforms to:** public.movie
			*/
		static var avi: DataType { .init(from: .avi) }

		/**
				The AIFF audio format
			
				**UTI:** public.aiff-audio
			
				**conforms to:** public.aifc-audio
			*/
		static var aiff: DataType { .init(from: .aiff) }

		/**
				The Microsoft waveform audio format (.wav).
			
				**UTI:** com.microsoft.waveform-audio
			
				**conforms to:** public.audio
			*/
		static var wav: DataType { .init(from: .wav) }

		/**
				The MIDI audio format.
			
				**UTI:** public.midi-audio
			
				**conforms to:** public.audio
			*/
		static var midi: DataType { .init(from: .midi) }

		/**
				The base type for playlists.
			
				**UTI:** public.playlist
			*/
		static var playlist: DataType { .init(from: .playlist) }

		/**
				An M3U or M3U8 playlist
			
				**UTI:** public.m3u-playlist
			
				**conforms to:** public.text, public.playlist
			*/
		static var m3uPlaylist: DataType { .init(from: .m3uPlaylist) }

		/**
				A user-browsable directory (i.e. not a package.)
			
				**UTI:** public.folder
			
				**conforms to:** public.directory
			*/
		static var folder: DataType { .init(from: .folder) }

		/**
				The root folder of a volume or mount point.
			
				**UTI:** public.volume
			
				**conforms to:** public.folder
			*/
		static var volume: DataType { .init(from: .volume) }

		/**
				A packaged directory.
			
				Bundles differ from packages in that a bundle has an internal file hierarchy
				that `CFBundle` can read, while packages are displayed to the user as if
				they were regular files. A single file system object can be both a package
				and a bundle.
			
				**UTI:** com.apple.package
			
				**conforms to:** public.directory
			*/
		static var package: DataType { .init(from: .package) }

		/**
				A directory conforming to one of the `CFBundle` layouts.
			
				Bundles differ from packages in that a bundle has an internal file hierarchy
				that `CFBundle` can read, while packages are displayed to the user as if
				they were regular files. A single file system object can be both a package
				and a bundle.
			
				**UTI:** com.apple.bundle
			
				**conforms to:** public.directory
			*/
		static var bundle: DataType { .init(from: .bundle) }

		/**
				The base type for bundle-based plugins.
			
				**UTI:** com.apple.plugin
			
				**conforms to:** com.apple.bundle, com.apple.package
			*/
		static var pluginBundle: DataType { .init(from: .pluginBundle) }

		/**
				A Spotlight metadata importer bundle.
			
				**UTI:** com.apple.metadata-importer
			
				**conforms to:** com.apple.plugin
			*/
		static var spotlightImporter: DataType { .init(from: .spotlightImporter) }

		/**
				A QuickLook preview generator bundle.
			
				**UTI:** com.apple.quicklook-generator
			
				**conforms to:** com.apple.plugin
			*/
		static var quickLookGenerator: DataType { .init(from: .quickLookGenerator) }

		/**
				An XPC service bundle.
			
				**UTI:** com.apple.xpc-service
			
				**conforms to:** com.apple.bundle, com.apple.package
			*/
		static var xpcService: DataType { .init(from: .xpcService) }

		/**
				A macOS or iOS framework bundle.
			
				**UTI:** com.apple.framework
			
				**conforms to:** com.apple.bundle
			*/
		static var framework: DataType { .init(from: .framework) }

		/**
				The base type for macOS and iOS applications.
			
				**UTI:** com.apple.application
			
				**conforms to:** public.executable
			*/
		static var application: DataType { .init(from: .application) }

		/**
				A bundled application.
			
				**UTI:** com.apple.application-bundle
			
				**conforms to:** com.apple.application, com.apple.bundle, com.apple.package
			*/
		static var applicationBundle: DataType { .init(from: .applicationBundle) }

		/**
				An application extension (.appex).
			
				**UTI:** com.apple.application-and-system-extension
			
				**conforms to:** com.apple.xpc-service
			*/
		static var applicationExtension: DataType { .init(from: .applicationExtension) }

		/**
				A UNIX executable (flat file.)
			
				**UTI:** public.unix-executable
			
				**conforms to:** public.data, public.executable
			*/
		static var unixExecutable: DataType { .init(from: .unixExecutable) }

		/**
				A Windows executable (.exe).
			
				**UTI:** com.microsoft.windows-executable
			
				**conforms to:** public.data, public.executable
			*/
		static var exe: DataType { .init(from: .exe) }

		/**
				A System Preferences pane.
			
				**UTI:** com.apple.systempreference.prefpane
			
				**conforms to:** com.apple.package, com.apple.bundle
			*/
		static var systemPreferencesPane: DataType { .init(from: .systemPreferencesPane) }

		/**
				an archive of files and directories
			
				**UTI:** public.archive
			*/
		static var archive: DataType { .init(from: .archive) }

		/**
				A GNU zip archive.
			
				**UTI:** org.gnu.gnu-zip-archive
			
				**conforms to:** public.data, public.archive
			*/
		static var gzip: DataType { .init(from: .gzip) }

		/**
				A bzip2 archive.
			
				**UTI:** public.bzip2-archive
			
				**conforms to:** public.data, public.archive
			*/
		static var bz2: DataType { .init(from: .bz2) }

		/**
				A zip archive.
			
				**UTI:** public.zip-archive
			
				**conforms to:** com.pkware.zip-archive
			*/
		static var zip: DataType { .init(from: .zip) }

		/**
				An Apple Archive.
			
				**UTI:** com.apple.archive
			
				**conforms to:** public.data, public.archive
			*/
		static var appleArchive: DataType { .init(from: .appleArchive) }

		/**
				A tar Archive.
			
				**UTI:** public.tar-archive
			
				**conforms to:** public.data, public.archive
			*/
		@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, *)
		static var tarArchive: DataType { .init(from: .tarArchive) }

		/**
				A base type for spreadsheet documents.
			
				**UTI:** public.spreadsheet
			
				**conforms to:** public.content
			*/
		static var spreadsheet: DataType { .init(from: .spreadsheet) }

		/**
				A base type for presentation documents.
			
				**UTI:** public.presentation
			
				**conforms to:** public.composite-content
			*/
		static var presentation: DataType { .init(from: .presentation) }

		/**
				A database store.
			
				**UTI:** public.database
			*/
		static var database: DataType { .init(from: .database) }

		/**
				A base type for messages (email, IM, etc.)
			
				**UTI:** public.message
			*/
		static var message: DataType { .init(from: .message) }

		/**
				contact information, e.g. for a person, group, organization
			
				**UTI:** public.contact
			*/
		static var contact: DataType { .init(from: .contact) }

		/**
				A vCard file.
			
				**UTI:** public.vcard
			
				**conforms to:** public.text, public.contact
			*/
		static var vCard: DataType { .init(from: .vCard) }

		/**
				A to-do item.
			
				**UTI:** public.to-do-item
			*/
		static var toDoItem: DataType { .init(from: .toDoItem) }

		/**
				A calendar event.
			
				**UTI:** public.calendar-event
			*/
		static var calendarEvent: DataType { .init(from: .calendarEvent) }

		/**
				An e-mail message.
			
				**UTI:** public.email-message
			
				**conforms to:** public.message
			*/
		static var emailMessage: DataType { .init(from: .emailMessage) }

		/**
				A base type for Apple Internet location files.
			
				**UTI:** com.apple.internet-location
			
				**conforms to:** public.data
			*/
		static var internetLocation: DataType { .init(from: .internetLocation) }

		/**
				Microsoft Internet shortcut files (.url).
			
				**UTI:** com.apple.internet-location
			
				**conforms to:** public.data
			*/
		static var internetShortcut: DataType { .init(from: .internetShortcut) }

		/**
				A base type for fonts.
			
				**UTI:** public.font
			*/
		static var font: DataType { .init(from: .font) }

		/**
				A bookmark.
			
				**UTI:** public.bookmark
			
				- SeeAlso: UTType.urlBookmarkData
			*/
		static var bookmark: DataType { .init(from: .bookmark) }

		/**
				PKCS#12 data.
			
				**UTI:** com.rsa.pkcs-12
			
				**conforms to:** public.data
			*/
		static var pkcs12: DataType { .init(from: .pkcs12) }

		/**
				An X.509 certificate.
			
				**UTI:** public.x509-certificate
			
				**conforms to:** public.data
			*/
		static var x509Certificate: DataType { .init(from: .x509Certificate) }

		/**
				The EPUB format.
			
				**UTI:** org.idpf.epub-container
			
				**conforms to:** public.data, public.composite-content
			*/
		static var epub: DataType { .init(from: .epub) }

		/**
				A base type for console logs.
			
				**UTI:** public.log
			*/
		static var log: DataType { .init(from: .log) }

		/**
				An Apple Haptics Audio Pattern file.
			
				**UTI:** com.apple.haptics.ahap
			*/
		@available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
		static var ahap: DataType { .init(from: .ahap) }

		/**
				A GeoJSON file.
			
				**UTI:** public.geojson
			*/
		@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, *)
		static var geoJSON: DataType { .init(from: .geoJSON) }

		/**
				Serialized LinkPresentation metadata.
			
				**UTI:** com.apple.linkpresentation.metadata
			
				**conforms to:** public.data
			*/
		@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, *)
		static var linkPresentationMetadata: DataType { .init(from: .linkPresentationMetadata) }
}
