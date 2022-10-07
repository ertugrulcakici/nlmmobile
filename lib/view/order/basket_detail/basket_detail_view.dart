import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlmmobile/core/services/auth/authservice.dart';
import 'package:nlmmobile/core/services/localization/locale_keys.g.dart';
import 'package:nlmmobile/core/services/navigation/navigation_service.dart';
import 'package:nlmmobile/core/services/theme/custom_colors.dart';
import 'package:nlmmobile/core/services/theme/custom_fonts.dart';
import 'package:nlmmobile/core/services/theme/custom_icons.dart';
import 'package:nlmmobile/core/services/theme/custom_images.dart';
import 'package:nlmmobile/core/services/theme/custom_theme_data.dart';
import 'package:nlmmobile/core/utils/extensions/ui_extensions.dart';
import 'package:nlmmobile/core/utils/helpers/popup_helper.dart';
import 'package:nlmmobile/product/constants/app_constants.dart';
import 'package:nlmmobile/product/models/order/basket_total_model.dart';
import 'package:nlmmobile/product/models/user/address_model.dart';
import 'package:nlmmobile/product/models/user/delivery_time_model.dart';
import 'package:nlmmobile/product/widgets/custom_appbar.dart';
import 'package:nlmmobile/product/widgets/custom_safearea.dart';
import 'package:nlmmobile/product/widgets/custom_text.dart';
import 'package:nlmmobile/product/widgets/terms/mesafeli_satis_sozlesmesi.dart';
import 'package:nlmmobile/product/widgets/terms/on_bilgilendirme_formu.dart';
import 'package:nlmmobile/product/widgets/try_again_widget.dart';
import 'package:nlmmobile/view/order/basket_detail/basket_detail_view_model.dart';
import 'package:nlmmobile/view/order/delivery_times/delivery_times.dart';
import 'package:nlmmobile/view/user/user_addresses/user_addresses_view.dart';

class BasketDetailView extends ConsumerStatefulWidget {
  final BasketTotalModel basketTotal;
  final List<AddressModel> addresses;
  const BasketDetailView(
      {Key? key, required this.basketTotal, required this.addresses})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BasketDetailState();
}

class _BasketDetailState extends ConsumerState<BasketDetailView> {
  late final ChangeNotifierProvider<BasketDetailViewModel> provider;
  bool isDisposed = false;

  @override
  void initState() {
    provider = ChangeNotifierProvider((ref) => BasketDetailViewModel(
        basketTotal: widget.basketTotal, addresses: widget.addresses));
    Future.delayed(Duration.zero, () {
      ref.read(provider).getData();
    });
    Future.delayed(const Duration(minutes: 5), () {
      if (isDisposed) {
        NavigationService.back();
        PopupHelper.showErrorDialog(
            errorMessage:
                "Uzun süredir işlem yapmadığınız için, işleminiz iptal edildi.");
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
        child: Scaffold(
      appBar:
          CustomAppBar.activeBack(LocaleKeys.BasketDetail_appbar_title.tr()),
      body: _body(),
    ));
  }

  Widget _body() {
    if (ref.watch(provider).isLoading == true) {
      return _loading();
    }
    if (ref.watch(provider).times == null) {
      return TryAgain(callBack: ref.read(provider).getData);
    }
    if (ref.watch(provider).addresses.isEmpty) {
      return _empty();
    }
    return _content();
  }

  Widget _loading() => Center(child: CustomImages.loading);

  Widget _empty() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.smw, vertical: 10.smh),
        decoration: BoxDecoration(
            color: CustomColors.primary,
            borderRadius: CustomThemeData.fullInfiniteRounded),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomText("Hiçbir adres bulunamadı",
                style: CustomFonts.bodyText2(CustomColors.primaryText)),
            Icon(Icons.location_city, color: CustomColors.primaryText),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.smw),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10.smh),
                _deliveryAddress(),
                SizedBox(height: 15.smh),
                _addressEquality(),
                ref.watch(provider).deliveryTaxSame
                    ? Container()
                    : SizedBox(height: 15.smh),
                ref.watch(provider).deliveryTaxSame
                    ? Container()
                    : _taxAddress(),
                SizedBox(height: 15.smh),
                _deliveryTime(),
                SizedBox(height: 15.smh),
                _paymentType(),
                SizedBox(height: 15.smh),
                ..._optionsList(),
                SizedBox(height: 15.smh),
                _orderNote(),
                SizedBox(height: 15.smh),
              ],
            ),
          ),
          _detailExpanded(),
        ],
      ),
    );
  }

  Widget _addressEquality() {
    return InkWell(
      onTap: () {
        ref.read(provider).deliveryTaxSame =
            !ref.read(provider).deliveryTaxSame;
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ref.watch(provider).deliveryTaxSame
              ? CustomIcons.checkbox_checked_icon
              : CustomIcons.checkbox_unchecked_icon,
          SizedBox(width: 10.smw),
          CustomText(
            "Fatura ve teslimat adresi aynı",
            style: CustomFonts.bodyText3(CustomColors.backgroundText),
          ),
        ],
      ),
    );
  }

  Widget _deliveryAddress() {
    return SizedBox(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextLocale(LocaleKeys.BasketDetail_choice_address,
                  style: CustomFonts.bodyText2(CustomColors.backgroundText)),
              _editCard()
            ],
          ),
          SizedBox(height: 10.smh),
          ...ref
              .watch(provider)
              .addresses
              .map((e) => InkWell(
                    onTap: () {
                      ref.read(provider).selectedDeliveryAddress = e;
                    },
                    child: _radioContainer(
                        title: e.addressHeader,
                        description: e.address,
                        isSelected:
                            ref.watch(provider).selectedDeliveryAddress == e),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _taxAddress() {
    return SizedBox(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText("Fatura adresi seçin",
                  style: CustomFonts.bodyText2(CustomColors.backgroundText)),
            ],
          ),
          SizedBox(height: 10.smh),
          ...ref
              .watch(provider)
              .addresses
              .map((e) => InkWell(
                    onTap: () {
                      ref.read(provider).selectedTaxAddress = e;
                    },
                    child: _radioContainer(
                        title: e.addressHeader,
                        description: e.address,
                        isSelected:
                            ref.watch(provider).selectedTaxAddress == e),
                  ))
              .toList(),
        ],
      ),
    );
  }

  _deliveryTime() {
    List<Widget> timesWidgets = ref.watch(provider).times!.map((e) {
      if (e.dates.length == 1) {
        return _hemenTeslimAlWidget(e);
      } else {
        return _teslimatSuresiSec(e);
      }
    }).toList();
    return SizedBox(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextLocale(LocaleKeys.BasketDetail_choice_time,
                  style: CustomFonts.bodyText2(CustomColors.backgroundText)),
            ],
          ),
          SizedBox(height: 10.smh),
          ...timesWidgets
        ],
      ),
    );
  }

  _paymentType() {
    return SizedBox(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextLocale(LocaleKeys.BasketDetail_choice_payment_method,
                  style: CustomFonts.bodyText2(CustomColors.backgroundText)),
            ],
          ),
          SizedBox(height: 10.smh),
          _radioContainer(
              title: "Kapıda ödeme",
              isSelected: true,
              description: "Kapıda nakit veya pos cihazı ile ödeme"),
        ],
      ),
    );
  }

  Widget _editCard() {
    return InkWell(
      onTap: () {
        NavigationService.navigateToPage(const UserAddressesView())
            .then((value) {
          ref.read(provider).getData();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.smw, vertical: 5.smh),
        decoration: BoxDecoration(
            borderRadius: CustomThemeData.fullInfiniteRounded,
            color: CustomColors.secondary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomIcons.edit_icon__small,
            SizedBox(width: 5.smw),
            CustomTextLocale(LocaleKeys.BasketDetail_edit,
                style: CustomFonts.bodyText5(CustomColors.secondaryText))
          ],
        ),
      ),
    );
  }

  Widget _detailExpanded() {
    return Container(
      height: 200.smh,
      width: AppConstants.designWidth.smw,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: CustomColors.paymentCard,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF50745C).withOpacity(0.5),
              blurRadius: 25,
              blurStyle: BlurStyle.inner)
        ],
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: ref.read(provider).createOrder,
            child: Container(
              height: 50.smh,
              width: 300.smw,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30)),
                  gradient: LinearGradient(
                    colors: CustomColors.paymentCard,
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomIcons.credit_card_icon_dark,
                  CustomTextLocale(LocaleKeys.BasketDetail_done_delivery,
                      style: CustomFonts.bodyText2(CustomColors.cardText))
                ],
              ),
            ),
          ),
          Container(
            color: Colors.transparent,
            margin: EdgeInsets.symmetric(horizontal: 25.smw, vertical: 10.smh),
            height: 80.smh,
            width: AppConstants.designWidth.smw,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextLocale(LocaleKeys.Basket_subtotal,
                        style: CustomFonts.bodyText4(CustomColors.cardText)),
                    CustomText(
                        ref
                            .watch(provider)
                            .basketTotal
                            .lineTotal
                            .toStringAsFixed(2),
                        style: CustomFonts.bodyText4(CustomColors.cardText))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextLocale(LocaleKeys.Basket_delivery_cost,
                        style: CustomFonts.bodyText4(CustomColors.cardText)),
                    CustomText(
                        ref
                            .watch(provider)
                            .basketTotal
                            .deliveryTotal
                            .toStringAsFixed(2),
                        style: CustomFonts.bodyText4(CustomColors.cardText))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextLocale(LocaleKeys.Basket_discount_cost,
                        style: CustomFonts.bodyText4(CustomColors.cardText)),
                    CustomText(
                        ref
                            .watch(provider)
                            .basketTotal
                            .promotionTotal
                            .toStringAsFixed(2),
                        style: CustomFonts.bodyText4(CustomColors.cardText))
                  ],
                )
              ],
            ),
          ),
          Divider(thickness: 1.smh, height: 1.smh),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 25.smw),
              color: Colors.transparent,
              height: 49.smh,
              width: AppConstants.designWidth.smw,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextLocale(LocaleKeys.Basket_total,
                      style: CustomFonts.bodyText2(CustomColors.cardText)),
                  CustomText(
                      ref
                          .watch(provider)
                          .basketTotal
                          .lineTotal
                          .toStringAsFixed(2),
                      style: CustomFonts.bodyText4(CustomColors.cardText))
                ],
              ))
        ],
      ),
    );
  }

  Widget _radioContainer(
      {required String title, String? description, required bool isSelected}) {
    return Container(
      constraints: BoxConstraints(minHeight: 60.smh),
      margin: EdgeInsets.only(bottom: 10.smh),
      decoration: BoxDecoration(
          color: CustomColors.primary, borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.smh),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                flex: 1,
                child: Center(
                  child: isSelected
                      ? CustomIcons.radio_checked_light_icon
                      : CustomIcons.radio_unchecked_light_icon,
                )),
            Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(title,
                        style: CustomFonts.bodyText4(CustomColors.primaryText)),
                    description != null
                        ? CustomText(description,
                            style:
                                CustomFonts.bodyText5(CustomColors.primaryText),
                            maxLines: 2)
                        : const SizedBox()
                  ],
                )),
          ],
        ),
      ),
    );
  }

  List<Widget> _optionsList() {
    List<Widget> options = [];
    options.add(_optionTile(
        title: "Zili Çalma",
        checked: ref.watch(provider).doNotRingBell,
        onTap: () {
          ref.read(provider).doNotRingBell = !ref.watch(provider).doNotRingBell;
        }));
    options.add(SizedBox(height: 15.smh));
    options.add(_optionTile(
        onTap: () {
          ref.read(provider).contactlessDelivery =
              !ref.watch(provider).contactlessDelivery;
        },
        title: "Temassız alışveriş",
        subtitle: "Ürünlerinizi kapınıza bırakıp sizi arıyacağız",
        checked: ref.watch(provider).contactlessDelivery));
    options.add(SizedBox(height: 15.smh));
    options.add(InkWell(
      onTap: () {
        ref.read(provider).acceptTerms = !ref.watch(provider).acceptTerms;
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ref.watch(provider).acceptTerms
              ? CustomIcons.checkbox_checked_icon
              : CustomIcons.checkbox_unchecked_icon,
          SizedBox(width: 10.smw),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                InkWell(
                    onTap: _mesafeliSatisSozlesmesiFunction,
                    child: CustomText("Mesafeli satış sözleşmesini",
                        style: CustomFonts.bodyText4(CustomColors.primary))),
                SizedBox(width: 5.smw),
                CustomText("ve",
                    style: CustomFonts.bodyText4(CustomColors.backgroundText)),
                SizedBox(width: 5.smw),
                InkWell(
                  onTap: _onBilgilendirmeFormuFunction,
                  child: CustomText("Ön Bilgilendirme",
                      style: CustomFonts.bodyText4(CustomColors.primary)),
                )
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                      onTap: _onBilgilendirmeFormuFunction,
                      child: CustomText("formunu",
                          style: CustomFonts.bodyText4(CustomColors.primary))),
                  SizedBox(width: 5.smw),
                  CustomText("okudum ve kabul ediyorum",
                      style:
                          CustomFonts.bodyText4(CustomColors.backgroundText)),
                ],
              )
            ],
          ),
        ],
      ),
    ));
    return options;
  }

  Widget _optionTile(
      {required String title,
      required bool checked,
      required Function() onTap,
      String? subtitle}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: 50.smh),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              checked
                  ? CustomIcons.checkbox_checked_icon
                  : CustomIcons.checkbox_unchecked_icon,
              SizedBox(width: 10.smw),
              subtitle == null
                  ? CustomText(title,
                      maxLines: 2,
                      style: CustomFonts.bodyText4(CustomColors.backgroundText))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(title,
                            maxLines: 2,
                            style: CustomFonts.bodyText4(
                                CustomColors.backgroundText)),
                        CustomText(subtitle,
                            maxLines: 2,
                            style: CustomFonts.bodyText5(CustomColors.primary))
                      ],
                    )
            ]),
      ),
    );
  }

  Widget _orderNote() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: CustomThemeData.fullRounded,
        color: CustomColors.primary,
      ),
      child: TextField(
        controller: ref.read(provider).noteController,
        maxLines: 3,
        style: CustomFonts.defaultField(CustomColors.primaryText),
        decoration: InputDecoration(
            hintText: "Sipariş notu",
            hintStyle: CustomFonts.defaultField(CustomColors.primaryText),
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.smw, vertical: 20.smh)),
      ),
    );
  }

  Future<void> _mesafeliSatisSozlesmesiFunction() async {
    NavigationService.navigateToPage(MesafeliSatisSozlesmesi(
      cariId: AuthService.currentUser!.id,
      deliveryAdressId: ref.watch(provider).selectedDeliveryAddress.id,
      invoiceAdressId: ref.watch(provider).selectedTaxAddress.id,
    ));
  }

  Future<void> _onBilgilendirmeFormuFunction() async {
    NavigationService.navigateToPage(OnBilgilendirmeFormuView(
      cariId: AuthService.currentUser!.id,
      deliveryAdressId: ref.watch(provider).selectedDeliveryAddress.id,
      invoiceAdressId: ref.watch(provider).selectedTaxAddress.id,
    ));
  }

  Widget _hemenTeslimAlWidget(DeliveryTimeModel deliveryTimeModel) {
    return InkWell(
      onTap: () {
        ref.read(provider).selectedHour =
            deliveryTimeModel.dates.first.hours.first;
        ref.read(provider).selectedDate =
            deliveryTimeModel.dates.first.dayDateTime;
        ref.read(provider).hemenTeslimAl = true;
      },
      child: Container(
        height: 60.smh,
        width: 330.smw,
        decoration: BoxDecoration(
            borderRadius: CustomThemeData.fullRounded,
            color: CustomColors.primary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                flex: 1,
                child: Center(
                  child: ref.watch(provider).hemenTeslimAl
                      ? CustomIcons.radio_checked_light_icon
                      : CustomIcons.radio_unchecked_light_icon,
                )),
            Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(deliveryTimeModel.typeName,
                        style: CustomFonts.bodyText2(CustomColors.primaryText)),
                    CustomText(
                        "Tahmini teslimat süresi: ${deliveryTimeModel.dates.first.hours.first}",
                        style: CustomFonts.bodyText4(CustomColors.primaryText)),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _teslimatSuresiSec(DeliveryTimeModel deliveryTimeModel) {
    return InkWell(
      onTap: () {
        NavigationService.navigateToPage<Map<String, String>?>(
                DeliveryTimesView(deliveryTimeModel: deliveryTimeModel))
            .then((value) {
          if (value != null) {
            ref.read(provider).selectedHour = value["Hour"]!;
            ref.read(provider).selectedDate = value["Date"]!;
            ref.read(provider).hemenTeslimAl = false;
          }
        });
      },
      child: Container(
        height: 60.smh,
        width: 330.smw,
        decoration: BoxDecoration(
            borderRadius: CustomThemeData.fullRounded,
            color: CustomColors.primary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                flex: 1,
                child: Center(
                    child: !ref.watch(provider).hemenTeslimAl
                        ? CustomIcons.radio_checked_light_icon
                        : CustomIcons.radio_unchecked_light_icon)),
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(deliveryTimeModel.typeName,
                      style: CustomFonts.bodyText2(CustomColors.primaryText)),
                  ref.watch(provider).hemenTeslimAl
                      ? Container()
                      : CustomText(ref.watch(provider).selectedHour!,
                          style:
                              CustomFonts.bodyText4(CustomColors.primaryText)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
