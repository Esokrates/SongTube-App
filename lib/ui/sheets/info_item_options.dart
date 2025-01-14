import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:line_icons/line_icons.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:provider/provider.dart';
import 'package:songtube/languages/languages.dart';
import 'package:songtube/main.dart';
import 'package:songtube/providers/content_provider.dart';
import 'package:songtube/services/content_service.dart';
import 'package:songtube/ui/info_item_renderer.dart';
import 'package:songtube/ui/sheet_phill.dart';
import 'package:songtube/ui/sheets/add_to_stream_playlist.dart';
import 'package:songtube/ui/sheets/snack_bar.dart';
import 'package:songtube/ui/text_styles.dart';

class InfoItemOptions extends StatelessWidget {
  const InfoItemOptions({
    required this.infoItem,
    this.onDelete,
    super.key});
  final dynamic infoItem;
  final Function()? onDelete;
  @override
  Widget build(BuildContext context) {
    ContentProvider contentProvider = Provider.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20)
      ),
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.center,
            child: BottomSheetPhill()),
          Padding(
            padding: const EdgeInsets.all(8.0).copyWith(left: 16, right: 16),
            child: InfoItemRenderer(infoItem: infoItem, editable: false),
          ),
          Divider(indent: 12, endIndent: 12, color: Theme.of(context).dividerColor),
          if (infoItem is PlaylistInfoItem)
          Builder(
            builder: (context) {
              final hasPlaylist = contentProvider.streamPlaylists.any((element) => element.name == infoItem.name);
              return _optionTile(context,
                title: hasPlaylist ? Languages.of(context)!.labelRemoveFromPlaylists : Languages.of(context)!.labelAddToPlaylists,
                subtitle: hasPlaylist ? Languages.of(context)!.labelThisActionCannotBeUndone : Languages.of(context)!.labelEditableOnceSaved,
                icon: LineIcons.heart,
                onTap: () async {
                  Navigator.pop(context);
                  showSnackbar(customSnackBar: CustomSnackBar(icon: hasPlaylist ? LineIcons.heartBroken : LineIcons.heart, title: hasPlaylist ? Languages.of(context)!.labelPlaylistRemoved : Languages.of(context)!.labelPlaylistSaved));
                  if (hasPlaylist) {
                    contentProvider.streamPlaylistRemove(infoItem.name);
                  } else {
                    final details = await ContentService.fetchPlaylistFromInfoItem(infoItem);
                    await details!.getStreams();
                    contentProvider.streamPlaylistCreate(infoItem.name, infoItem.uploaderName!, details.streams!);
                  }
                }
              );
            }
          ),
          if (infoItem is StreamInfoItem)
          _optionTile(context,
            title: Languages.of(context)!.labelAddVideoToPlaylist,
            subtitle: Languages.of(context)!.labelAddVideoToPlaylistDescription,
            icon: LineIcons.list,
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(context: internalNavigatorKey.currentContext!, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (context) {
                return AddToStreamPlaylist(stream: infoItem);
              });
            }
          ),
          if (infoItem is StreamInfoItem)
          Builder(
            builder: (context) {
              final hasVideo = contentProvider.favoriteVideos.any((element) => element.id == infoItem.id);
              return _optionTile(context,
                title: hasVideo ? Languages.of(context)!.labelRemoveFromFavorites : Languages.of(context)!.labelSaveToFavorites,
                subtitle: hasVideo ? Languages.of(context)!.labelRemoveFromFavoritesDescription : Languages.of(context)!.labelSaveToFavoritesDescription,
                icon: LineIcons.star,
                onTap: () {
                  Navigator.pop(context);
                  showSnackbar(customSnackBar: CustomSnackBar(icon: hasVideo ? LineIcons.trash : LineIcons.star, title: hasVideo ? Languages.of(context)!.labelVideoRemovedFromFavorites : Languages.of(context)!.labelVideoAddedToFavorites));
                  if (hasVideo) {
                    contentProvider.removeVideoFromFavorites(infoItem.id);
                  } else {
                    contentProvider.saveVideoToFavorites(infoItem);
                  }
                }
              );
            }
          ),
          _optionTile(context,
            title: infoItem is StreamInfoItem ? Languages.of(context)!.labelShareVideo : Languages.of(context)!.labelSharePlaylist,
            subtitle: Languages.of(context)!.labelShareDescription,
            icon: LineIcons.share,
            onTap: () {
              FlutterShare.share(
                title: infoItem.name!,
                text: '${infoItem.url}'
              );
            }
          ),
          if (onDelete != null)
          _optionTile(context, title: Languages.of(context)!.labelDelete, subtitle: Languages.of(context)!.labelRemoveThisVideoFromThisList, icon: LineIcons.trash, onTap: () {
            Navigator.pop(context);
            onDelete!();
          })
        ],
      ),
    );
  }

  Widget _optionTile(BuildContext context, {required String title, required String subtitle, required IconData icon, required Function() onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 6),
        height: kToolbarHeight,
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Icon(icon, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: smallTextStyle(context).copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: tinyTextStyle(context, opacity: 0.6))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}