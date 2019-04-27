import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/connect/meal_plan/meal_plan_repository.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/model/meal_plan/canteen.dart';
import 'package:guide7/model/meal_plan/meal_plan.dart';
import 'package:guide7/ui/util/ui_util.dart';
import 'package:guide7/ui/view/meal_plan/meal_plan_widget.dart';
import 'package:guide7/util/custom_colors.dart';
import 'package:intl/intl.dart';

/// View for meal plans.
class MealPlanView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MealPlanViewState();
}

/// State of the meal plan view.
class _MealPlanViewState extends State<MealPlanView> {
  /// Controller for paging.
  PageController _controller;

  /// The currently selected date.
  DateTime _now;

  /// Offset of the date calculated from [_now].
  int _dateOffset = 0;

  /// Future loading the meal plan.
  Future<MealPlan> _mealPlanFuture;

  @override
  void initState() {
    super.initState();

    _controller = PageController(initialPage: _dateOffset);
    _now = DateTime.now();
  }

  @override
  Widget build(BuildContext context) => UIUtil.getScaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              _buildAppBar(),
              _buildControlBar(),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemBuilder: (BuildContext context, int pageIndex) {
                    return RefreshIndicator(
                      onRefresh: () => _loadMealPlan(_now.add(Duration(days: _dateOffset)), fromCache: false),
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: _buildContent(pageIndex),
                      ),
                    );
                  },
                  onPageChanged: (pageIndex) {
                    setState(() {
                      _dateOffset = pageIndex;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      );

  /// Build the views app bar.
  Widget _buildAppBar() => AppBar(
        title: Text(AppLocalizations.of(context).mealPlan),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: BackButton(
          color: CustomColors.slateGrey,
        ),
      );

  /// Build the control bar to select the date of the meal plan to show.
  Widget _buildControlBar() {
    DateFormat dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);

    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          color: CustomColors.slateGrey,
          onPressed: _dateOffset == 0
              ? null
              : () {
                  _switchToPage(false);
                },
        ),
        Expanded(
          child: Text(
            dateFormat.format(_now.add(Duration(days: _dateOffset))),
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.arrow_forward_ios,
          ),
          color: CustomColors.slateGrey,
          onPressed: () {
            _switchToPage(true);
          },
        ),
      ],
    );
  }

  /// Build views content.
  Widget _buildContent(int dateOffset) {
    _mealPlanFuture = _loadMealPlan(_now.add(Duration(days: dateOffset)));

    return FutureBuilder(
      future: _mealPlanFuture,
      builder: (BuildContext context, AsyncSnapshot<MealPlan> snapshot) {
        Widget widget;

        if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
          widget = MealPlanWidget(
            mealPlan: snapshot.data,
          );
        } else if (!snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
          widget = Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              child: Text(
                AppLocalizations.of(context).noMealPlan,
                style: TextStyle(fontFamily: "NotoSerifTC"),
              ),
            ),
          );
        } else if (snapshot.hasError && snapshot.connectionState == ConnectionState.done) {
          widget = Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 30.0),
            child: Text(
              AppLocalizations.of(context).mealPlanError,
              style: TextStyle(fontFamily: "NotoSerifTC"),
            ),
          );
        } else {
          widget = Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 30.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return widget;
      },
    );
  }

  /// Load the meal plan for the passed date.
  Future<MealPlan> _loadMealPlan(
    DateTime date, {
    bool fromCache = true,
  }) async {
    Repository repository = Repository();
    MealPlanRepository mealPlanRepository = repository.getMealPlanRepository();

    return await mealPlanRepository.loadMealPlan(Canteen(id: 141, name: ""), date);
  }

  /// Switch to previous or next page.
  void _switchToPage(bool next) {
    if (next) {
      _controller.nextPage(
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      );
    } else {
      _controller.previousPage(
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      );
    }
  }
}
