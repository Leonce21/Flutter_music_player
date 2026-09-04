import 'package:flutter/material.dart';
import '../../../../core/widgets/library_tab_bar.dart';
import '../../../../core/widgets/mume_scaffold.dart';
import '../widgets/suggested_tab.dart';
import '../../../library/presentation/widgets/tabs.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: libraryTabs.length,
      child: const MumeScaffold(
        bottom: LibraryTabBar(),
        body: TabBarView(children: [
          // SuggestedTab(),
          SongsTab(),
          ArtistsTab(),
          AlbumsTab(),
          FoldersTab(),
        ]),
      ),
    );
  }
}