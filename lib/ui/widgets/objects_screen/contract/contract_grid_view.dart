import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/database/local_database.dart';
import '../../../../core/enums/font_size_value.dart';
import '../../../../core/model/contract_dto.dart';

import '../../../../core/provider/contract_provider.dart';

import '../../../../core/provider/theme_changer.dart';
import 'contract_card.dart';

class ContractGridView extends StatefulWidget {
  const ContractGridView({super.key});

  @override
  State<ContractGridView> createState() => _ContractGridViewState();
}

class _ContractGridViewState extends State<ContractGridView> {
  int _pageIndex = 0;
  final _pageController = PageController(initialPage: 0, keepPage: true);

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabase>(context);

    final contractProvider = Provider.of<ContractProvider>(context);
    final themeProvider = Provider.of<ThemeChanger>(context);

    return StreamBuilder(
      stream: db.contractDao.watchAllContracts(false),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return const Center(
            child: Text(
              'Es wurden noch keine Verträge erstellt. \n Drücke jetzt auf das Plus um ein Vertrag zu erstellen.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          );
        }

        if (items.length != contractProvider.getAllContractLength) {
          contractProvider.convertData(data: items, db: db, isArchived: false);
        }

        contractProvider.prepareProvider(db, false);

        final first = contractProvider.getFirstContracts;
        final second = contractProvider.getSecondContracts;

        if (_pageController.positions.isNotEmpty) {
          int currentPage = _pageController.page! > 0.5 ? 1 : 0;

          if (_pageIndex != currentPage && _pageController.page! < 1.0) {
            _pageIndex = 0;
          }
        }

        bool isLargeText = themeProvider.getFontSizeValue == FontSizeValue.large
            ? true
            : false;

        double height = 180;

        if (first.length == 1 && second.isEmpty) {
          if (isLargeText) {
            height = 190;
          } else {
            height = 180;
          }
        } else {
          if (isLargeText) {
            height = 400;
          } else {
            height = 370;
          }
        }

        return Column(
          children: [
            SizedBox(
              height: height,
              child: PageView.builder(
                controller: _pageController,
                physics: const AlwaysScrollableScrollPhysics(),
                onPageChanged: (value) {
                  setState(() {
                    _pageIndex = value;
                  });
                },
                itemCount: first.length,
                itemBuilder: (context, index) {
                  ContractDto contract1 = first.elementAt(index);
                  ContractDto? contract2;

                  if (index < second.length) {
                    contract2 = second.elementAt(index);
                  }

                  return Column(
                    children: [
                      ContractCard(
                        contractDto: contract1,
                      ),
                      if (contract2 != null)
                        ContractCard(contractDto: contract2),
                    ],
                  );
                },
              ),
            ),
            AnimatedSmoothIndicator(
              activeIndex: _pageIndex,
              count: first.length,
              effect: WormEffect(
                activeDotColor: Theme.of(context).primaryColor,
                dotHeight: 10,
                dotWidth: 10,
              ),
            ),
          ],
        );
      },
    );
  }
}
