import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_wechat/constant/constant.dart';
import 'package:flutter_wechat/constant/style.dart';

import 'package:flutter_wechat/routers/fluro_navigator.dart';
import 'package:flutter_wechat/components/photo_browser/photo_browser_router.dart';

import 'package:flutter_wechat/components/list_tile/mh_list_tile.dart';
import 'package:flutter_wechat/model/picture/picture.dart';
import 'package:flutter_wechat/model/user/user.dart';
import 'package:flutter_wechat/components/photo_browser/photo.dart';

class ContactInfoMoments extends StatelessWidget {
  ContactInfoMoments({
    Key key,
    @required this.user,
  }) : super(key: key);

  /// 用户信息
  final User user;

  /// photos
  final List<Photo> _photos = new List();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildChildWidget(context),
    );
  }

  void _openPhotoBrowser(BuildContext context, final int index) {
    // 先将photos 装成字符串
    final String jsonStr = jsonEncode(_photos);
    // 跳转
    NavigatorUtils.push(context,
        '${PhotoBrowserRouter.photoBrowserPage}?initialIndex=$index&photos=${Uri.encodeComponent(jsonStr)}',
        transition: TransitionType.fadeIn);
  }

  /// 构建子部件
  Widget _buildChildWidget(BuildContext context) {
    Widget leading = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 50.0,
      ),
      child: Text(
        '朋友圈',
        style: TextStyle(fontSize: 16.0, color: Style.pTextColor),
      ),
    );

    // 计算朋友圈图片的大小
    // 获取屏幕的物理尺寸宽度
    final double screenW = ScreenUtil.screenWidthDp;
    // 计算父部件的宽度
    final double momentsW = screenW -
        2 * Constant.pEdgeInset -
        8.0 -
        50.0 -
        2 * Constant.pEdgeInset;
    // 就算图片的大小
    final double imageWH = momentsW / 5.0;
    final double leftPadding = 5.0;
    final List<Widget> children = [];
    if (user.pictures != null && user.pictures.length != 0) {
      final count = user.pictures.length;
      for (var i = 0; i < count; i++) {
        final Picture picture = user.pictures[i];

        final Photo photo = Photo(url: picture.big.url, tag: i.toString());
        _photos.add(photo);

        Widget w = Container(
          padding: EdgeInsets.only(left: leftPadding),
          child: InkWell(
              onTap: () {
                _openPhotoBrowser(context, i);
              },
              child: Hero(
                tag: i.toString(),
                child: CachedNetworkImage(
                  imageUrl: picture.small.url,
                  width: imageWH - leftPadding,
                  height: imageWH - leftPadding,
                  fit: BoxFit.cover,
                  placeholder: (context, url) {
                    return Image.asset(
                      Constant.assetsImagesDefault +
                          'ChatBackgroundThumb_00_100x100.png',
                      width: imageWH - leftPadding,
                      height: imageWH - leftPadding,
                    );
                  },
                  errorWidget: (context, url, error) {
                    return Image.asset(
                      Constant.assetsImagesDefault +
                          'ChatBackgroundThumb_00_100x100.png',
                      width: imageWH - leftPadding,
                      height: imageWH - leftPadding,
                    );
                  },
                ),
              )),
        );
        children.add(w);
      }
    }
    Widget middle = Padding(
      padding: EdgeInsets.symmetric(horizontal: Constant.pEdgeInset),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: children,
        ),
      ),
    );

    Widget trailing = Image.asset(
      Constant.assetsImagesArrow + 'tableview_arrow_8x13.png',
      width: 8.0,
      height: 13.0,
    );

    return MHListTile(
      contentPadding: EdgeInsets.all(Constant.pEdgeInset),
      allowTap: false,
      leading: leading,
      middle: middle,
      trailing: trailing,
      dividerIndent: Constant.pEdgeInset,
    );
  }
}
