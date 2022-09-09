import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlmmobile/core/services/localization/locale_keys.g.dart';
import 'package:nlmmobile/core/services/navigation/navigation_service.dart';
import 'package:nlmmobile/core/services/theme/custom_colors.dart';
import 'package:nlmmobile/core/services/theme/custom_fonts.dart';
import 'package:nlmmobile/core/services/theme/custom_icons.dart';
import 'package:nlmmobile/core/services/theme/custom_theme_data.dart';
import 'package:nlmmobile/core/utils/extensions/ui_extensions.dart';
import 'package:nlmmobile/product/constants/app_constants.dart';
import 'package:nlmmobile/product/models/user/user_orders_model.dart';
import 'package:nlmmobile/product/widgets/custom_appbar.dart';
import 'package:nlmmobile/product/widgets/custom_safearea.dart';
import 'package:nlmmobile/product/widgets/custom_text.dart';
import 'package:nlmmobile/view/user/user_order_details/user_order_details_view.dart';
import 'package:nlmmobile/view/user/user_orders/user_orders_view_model.dart';

class UserOrdersView extends ConsumerStatefulWidget {
  const UserOrdersView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserOrdersViewState();
}

class _UserOrdersViewState extends ConsumerState<UserOrdersView> {
  late final ChangeNotifierProvider<UserOrdersViewModel> provider;

  @override
  void initState() {
    provider = ChangeNotifierProvider((ref) => UserOrdersViewModel());
    Future.delayed(Duration.zero, () {
      ref.read(provider).getOrders();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: Scaffold(
        appBar:
            CustomAppBar.activeBack(LocaleKeys.UserOrders_appbar_title.tr()),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [_filters(), ..._cards()],
          ),
        ),
      ),
    );
  }

  Widget _filters() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.smh),
      height: 60.smh,
      width: AppConstants.designWidth.smw,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: ref.watch(provider).statuses.length,
        itemBuilder: (context, index) => InkWell(
          onTap: () => ref
              .watch(provider)
              .addRemoveFilter(ref.watch(provider).statuses[index]),
          child: AnimatedContainer(
            duration: CustomThemeData.animationDurationShort,
            curve: Curves.easeInOut,
            margin: EdgeInsets.symmetric(horizontal: 10.smw),
            height: 60.smh,
            constraints: BoxConstraints(
                minWidth: ref.watch(provider).statuses.length > 1
                    ? (AppConstants.designWidth /
                                ref.watch(provider).statuses.length -
                            0.5)
                        .smw
                    : 360.smw),
            decoration: BoxDecoration(
              borderRadius: CustomThemeData.fullRounded,
              border: Border.all(color: CustomColors.primary, width: 1),
              color: ref
                      .watch(provider)
                      .filterStatuses
                      .contains(ref.watch(provider).statuses[index])
                  ? CustomColors.primary
                  : CustomColors.card,
            ),
            padding: EdgeInsets.symmetric(horizontal: 10.smw, vertical: 5.smh),
            child: Center(
              child: CustomText(
                ref.watch(provider).statuses[index],
                style: CustomFonts.bigButton(ref
                        .watch(provider)
                        .filterStatuses
                        .contains(ref.watch(provider).statuses[index])
                    ? CustomColors.primaryText
                    : CustomColors.cardText),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _cards() {
    return List.generate(
        ref.watch(provider).filtered.length, (index) => _card(index));
  }

  Widget _card(int index) {
    UserOrdersModel order = ref.watch(provider).filtered[index];
    return InkWell(
      onTap: () {
        NavigationService.navigateToPage(
            UserOrderDetailsView(orderTitle: order));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.smw, vertical: 10.smh),
        margin: EdgeInsets.only(bottom: 10.smh),
        height: 200.smh,
        width: AppConstants.designWidth.smw,
        color: CustomColors.card2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding:
                  EdgeInsets.only(left: 10.smw, right: 10.smw, top: 10.smh),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomTextLocale(
                            LocaleKeys.UserOrders_no,
                            style: CustomFonts.bodyText4(
                                CustomColors.card2TextPale),
                          ),
                          CustomText(order.FicheNo,
                              style:
                                  CustomFonts.bodyText4(CustomColors.card2Text))
                        ],
                      ),
                      Row(
                        children: [
                          CustomTextLocale(
                            LocaleKeys.UserOrders_date,
                            style: CustomFonts.bodyText4(
                                CustomColors.card2TextPale),
                          ),
                          CustomText(order.OrderDate.toString(),
                              style:
                                  CustomFonts.bodyText4(CustomColors.card2Text))
                        ],
                      ),
                      Row(
                        children: [
                          CustomTextLocale(
                            LocaleKeys.UserOrders_status,
                            style: CustomFonts.bodyText4(
                                CustomColors.card2TextPale),
                          ),
                          CustomText(order.StatusName,
                              style:
                                  CustomFonts.bodyText4(CustomColors.card2Text))
                        ],
                      )
                    ],
                  ),
                  Column(// resim ve ürün sayısı
                      children: [
                    CustomTextLocale(LocaleKeys.UserOrders_order_total,
                        style:
                            CustomFonts.bodyText4(CustomColors.card2TextPale)),
                    CustomText("${order.Total} TL",
                        style: CustomFonts.bodyText3(CustomColors.card2Text)),
                  ])
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 5.smw),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.all(5.smh),
                        child: ClipRRect(
                          borderRadius: CustomThemeData.fullRounded,
                          child: Image.network("https://picsum.photos/200",
                              height: 90.smh, width: 90.smh),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(5.smh),
                        child: ClipRRect(
                          borderRadius: CustomThemeData.fullRounded,
                          child: Image.network("https://picsum.photos/200",
                              height: 90.smh, width: 90.smh),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      CustomTextLocale(LocaleKeys.UserOrders_total_product,
                          args: [order.LineCount.toString()],
                          maxLines: 3,
                          textAlign: TextAlign.center,
                          style: CustomFonts.bodyText1(CustomColors.card2Text)),
                      SizedBox(width: 20.smw),
                      CustomIcons.forward_icon_dark
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
