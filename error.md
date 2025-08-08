======== Exception caught by rendering library =====================================================
The following assertion was thrown during performLayout():
RenderFlex children have non-zero flex but incoming height constraints are unbounded.

When a column is in a parent that does not provide a finite height constraint, for example if it is in a vertical scrollable, it will try to shrink-wrap its children along the vertical axis. Setting a flex on a child (e.g. using Expanded) indicates that the child is to expand to fill the remaining space in the vertical direction.
These two directives are mutually exclusive. If a parent is to shrink-wrap its child, the child cannot simultaneously expand to fit its parent.

Consider setting mainAxisSize to MainAxisSize.min and using FlexFit.loose fits for the flexible children (using Flexible rather than Expanded). This will allow the flexible children to size themselves to less than the infinite remaining space they would otherwise be forced to take, and then will cause the RenderFlex to shrink-wrap the children rather than expanding to fit the maximum constraints provided by the parent.

If this message did not help you determine the problem, consider using debugDumpRenderTree():
  https://flutter.dev/to/debug-render-layer
  https://api.flutter.dev/flutter/rendering/debugDumpRenderTree.html
The affected RenderFlex is: RenderFlex#1afc8 relayoutBoundary=up3 NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
  parentData: offset=Offset(0.0, 0.0); flex=null; fit=null (can use size)
  constraints: BoxConstraints(0.0<=w<=370.0, 0.0<=h<=Infinity)
  size: MISSING
  direction: vertical
  mainAxisAlignment: start
  mainAxisSize: max
  crossAxisAlignment: center
  verticalDirection: down
  spacing: 0.0
...  child 1: RenderPadding#64a2b NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...    parentData: offset=Offset(0.0, 0.0); flex=null; fit=null
...    constraints: MISSING
...    size: MISSING
...    padding: EdgeInsets.all(16.0)
...    textDirection: ltr
...    child: RenderDecoratedBox#ac62e NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...      parentData: offset=Offset(0.0, 0.0)
...      constraints: MISSING
...      size: MISSING
...      decoration: BoxDecoration
...        color: Color(alpha: 1.0000, red: 0.8902, green: 0.9490, blue: 0.9922, colorSpace: ColorSpace.sRGB)
...        border: Border.all(BorderSide(color: Color(alpha: 1.0000, red: 0.5647, green: 0.7922, blue: 0.9765, colorSpace: ColorSpace.sRGB)))
...        borderRadius: BorderRadius.circular(12.0)
...      configuration: ImageConfiguration(bundle: PlatformAssetBundle#95326(), devicePixelRatio: 3.0, locale: en_US, textDirection: TextDirection.ltr, platform: iOS)
...      child: RenderPadding#05862 NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...        parentData: <none>
...        constraints: MISSING
...        size: MISSING
...        padding: EdgeInsets.all(17.0)
...        textDirection: ltr
...        child: RenderFlex#03f20 NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...          parentData: offset=Offset(0.0, 0.0)
...          constraints: MISSING
...          size: MISSING
...          direction: vertical
...          mainAxisAlignment: start
...          mainAxisSize: max
...          crossAxisAlignment: center
...          verticalDirection: down
...          spacing: 0.0
...  child 2: RenderConstrainedBox#cbde9 NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...    parentData: offset=Offset(0.0, 0.0); flex=1; fit=FlexFit.loose
...    constraints: MISSING
...    size: MISSING
...    additionalConstraints: BoxConstraints(0.0<=w<=Infinity, h=524.4)
...    child: RenderPadding#1ccfe NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...      parentData: <none>
...      constraints: MISSING
...      size: MISSING
...      padding: EdgeInsets(16.0, 0.0, 16.0, 0.0)
...      textDirection: ltr
...      child: _RenderScrollSemantics#7b9f3 NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...        parentData: offset=Offset(0.0, 0.0)
...        constraints: MISSING
...        semantic boundary
...        size: MISSING
...        child: RenderPointerListener#df2dc NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...          parentData: <none>
...          constraints: MISSING
...          size: MISSING
...          behavior: deferToChild
...          listeners: signal
...  child 3: RenderConstrainedBox#cb168 NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...    parentData: offset=Offset(0.0, 0.0); flex=null; fit=null
...    constraints: MISSING
...    size: MISSING
...    additionalConstraints: BoxConstraints(w=Infinity, 0.0<=h<=Infinity)
...    child: RenderPadding#824fd NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...      parentData: <none>
...      constraints: MISSING
...      size: MISSING
...      padding: EdgeInsets.all(16.0)
...      textDirection: ltr
...      child: RenderFlex#288e5 NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...        parentData: offset=Offset(0.0, 0.0)
...        constraints: MISSING
...        size: MISSING
...        direction: horizontal
...        mainAxisAlignment: start
...        mainAxisSize: max
...        crossAxisAlignment: center
...        textDirection: ltr
...        verticalDirection: down
...        spacing: 0.0
...        child 1: RenderSemanticsAnnotations#e742b NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...          parentData: offset=Offset(0.0, 0.0); flex=1; fit=FlexFit.tight
...          constraints: MISSING
...          semantic boundary
...          size: MISSING
...        child 2: RenderConstrainedBox#597d3 NEEDS-LAYOUT NEEDS-PAINT
...          parentData: offset=Offset(0.0, 0.0); flex=null; fit=null
...          constraints: MISSING
...          size: MISSING
...          additionalConstraints: BoxConstraints(w=16.0, 0.0<=h<=Infinity)
...        child 3: RenderSemanticsAnnotations#0f483 NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...          parentData: offset=Offset(0.0, 0.0); flex=2; fit=FlexFit.tight
...          constraints: MISSING
...          semantic boundary
...          size: MISSING
The creator information is set to: Column ← ValueListenableBuilder<StudentQuizState> ← Column ← Padding ← _SingleChildViewport ← IgnorePointer-[GlobalKey#a57de] ← Semantics ← Listener ← _GestureSemantics ← RawGestureDetector-[LabeledGlobalKey<RawGestureDetectorState>#08465] ← Listener ← _ScrollableScope ← ⋯
The nearest ancestor providing an unbounded width constraint is: _RenderSingleChildViewport#22f2c NEEDS-LAYOUT
...  needs compositing
...  parentData: <none> (can use size)
...  constraints: BoxConstraints(w=402.0, h=260.7)
...  layer: OffsetLayer#58e37
...    engine layer: OffsetEngineLayer#a05b4
...    handles: 2
...    offset: Offset(0.0, 517.3)
...  size: Size(402.0, 260.7)
...  offset: Offset(0.0, -0.0)

See also: https://flutter.dev/unbounded-constraints

If none of the above helps enough to fix this problem, please don't hesitate to file a bug:
  https://github.com/flutter/flutter/issues/new?template=2_bug.yml
The relevant error-causing widget was: 
  Column Column:file:///Users/iqbalmahamud/classmate/lib/views/class_details_student/class_details_student_view.dart:797:12
When the exception was thrown, this was the stack: 
#0      RenderFlex.performLayout.<anonymous closure> (package:flutter/src/rendering/flex.dart:1250:9)
#1      RenderFlex.performLayout (package:flutter/src/rendering/flex.dart:1253:6)
#2      RenderObject.layout (package:flutter/src/rendering/object.dart:2715:7)
#3      ChildLayoutHelper.layoutChild (package:flutter/src/rendering/layout_helper.dart:62:11)
#4      RenderFlex._computeSizes (package:flutter/src/rendering/flex.dart:1161:28)
#5      RenderFlex.performLayout (package:flutter/src/rendering/flex.dart:1255:32)
#6      RenderObject.layout (package:flutter/src/rendering/object.dart:2715:7)
#7      RenderPadding.performLayout (package:flutter/src/rendering/shifted_box.dart:243:12)
#8      RenderObject.layout (package:flutter/src/rendering/object.dart:2715:7)
#9      _RenderSingleChildViewport.performLayout (package:flutter/src/widgets/single_child_scroll_view.dart:493:14)
#10     RenderObject._layoutWithoutResize (package:flutter/src/rendering/object.dart:2548:7)
#11     PipelineOwner.flushLayout (package:flutter/src/rendering/object.dart:1112:18)
#12     PipelineOwner.flushLayout (package:flutter/src/rendering/object.dart:1125:15)
#13     RendererBinding.drawFrame (package:flutter/src/rendering/binding.dart:616:23)
#14     WidgetsBinding.drawFrame (package:flutter/src/widgets/binding.dart:1231:13)
#15     RendererBinding._handlePersistentFrameCallback (package:flutter/src/rendering/binding.dart:482:5)
#16     SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1442:15)
#17     SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1355:9)
#18     SchedulerBinding._handleDrawFrame (package:flutter/src/scheduler/binding.dart:1208:5)
#19     _invoke (dart:ui/hooks.dart:316:13)
#20     PlatformDispatcher._drawFrame (dart:ui/platform_dispatcher.dart:428:5)
#21     _drawFrame (dart:ui/hooks.dart:288:31)
The following RenderObject was being processed when the exception was fired: RenderFlex#1afc8 relayoutBoundary=up3 NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...  parentData: offset=Offset(0.0, 0.0); flex=null; fit=null (can use size)
...  constraints: BoxConstraints(0.0<=w<=370.0, 0.0<=h<=Infinity)
...  size: MISSING
...  direction: vertical
...  mainAxisAlignment: start
...  mainAxisSize: max
...  crossAxisAlignment: center
...  verticalDirection: down
...  spacing: 0.0
RenderObject: RenderFlex#1afc8 relayoutBoundary=up3 NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
  parentData: offset=Offset(0.0, 0.0); flex=null; fit=null (can use size)
  constraints: BoxConstraints(0.0<=w<=370.0, 0.0<=h<=Infinity)
  size: MISSING
  direction: vertical
  mainAxisAlignment: start
  mainAxisSize: max
  crossAxisAlignment: center
  verticalDirection: down
  spacing: 0.0
...  child 1: RenderPadding#64a2b NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...    parentData: offset=Offset(0.0, 0.0); flex=null; fit=null
...    constraints: MISSING
...    size: MISSING
...    padding: EdgeInsets.all(16.0)
...    textDirection: ltr
...    child: RenderDecoratedBox#ac62e NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...      parentData: offset=Offset(0.0, 0.0)
...      constraints: MISSING
...      size: MISSING
...      decoration: BoxDecoration
...        color: Color(alpha: 1.0000, red: 0.8902, green: 0.9490, blue: 0.9922, colorSpace: ColorSpace.sRGB)
...        border: Border.all(BorderSide(color: Color(alpha: 1.0000, red: 0.5647, green: 0.7922, blue: 0.9765, colorSpace: ColorSpace.sRGB)))
...        borderRadius: BorderRadius.circular(12.0)
...      configuration: ImageConfiguration(bundle: PlatformAssetBundle#95326(), devicePixelRatio: 3.0, locale: en_US, textDirection: TextDirection.ltr, platform: iOS)
...      child: RenderPadding#05862 NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...        parentData: <none>
...        constraints: MISSING
...        size: MISSING
...        padding: EdgeInsets.all(17.0)
...        textDirection: ltr
...        child: RenderFlex#03f20 NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...          parentData: offset=Offset(0.0, 0.0)
...          constraints: MISSING
...          size: MISSING
...          direction: vertical
...          mainAxisAlignment: start
...          mainAxisSize: max
...          crossAxisAlignment: center
...          verticalDirection: down
...          spacing: 0.0
...  child 2: RenderConstrainedBox#cbde9 NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...    parentData: offset=Offset(0.0, 0.0); flex=1; fit=FlexFit.loose
...    constraints: MISSING
...    size: MISSING
...    additionalConstraints: BoxConstraints(0.0<=w<=Infinity, h=524.4)
...    child: RenderPadding#1ccfe NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...      parentData: <none>
...      constraints: MISSING
...      size: MISSING
...      padding: EdgeInsets(16.0, 0.0, 16.0, 0.0)
...      textDirection: ltr
...      child: _RenderScrollSemantics#7b9f3 NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...        parentData: offset=Offset(0.0, 0.0)
...        constraints: MISSING
...        semantic boundary
...        size: MISSING
...        child: RenderPointerListener#df2dc NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...          parentData: <none>
...          constraints: MISSING
...          size: MISSING
...          behavior: deferToChild
...          listeners: signal
...  child 3: RenderConstrainedBox#cb168 NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...    parentData: offset=Offset(0.0, 0.0); flex=null; fit=null
...    constraints: MISSING
...    size: MISSING
...    additionalConstraints: BoxConstraints(w=Infinity, 0.0<=h<=Infinity)
...    child: RenderPadding#824fd NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...      parentData: <none>
...      constraints: MISSING
...      size: MISSING
...      padding: EdgeInsets.all(16.0)
...      textDirection: ltr
...      child: RenderFlex#288e5 NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...        parentData: offset=Offset(0.0, 0.0)
...        constraints: MISSING
...        size: MISSING
...        direction: horizontal
...        mainAxisAlignment: start
...        mainAxisSize: max
...        crossAxisAlignment: center
...        textDirection: ltr
...        verticalDirection: down
...        spacing: 0.0
...        child 1: RenderSemanticsAnnotations#e742b NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...          parentData: offset=Offset(0.0, 0.0); flex=1; fit=FlexFit.tight
...          constraints: MISSING
...          semantic boundary
...          size: MISSING
...        child 2: RenderConstrainedBox#597d3 NEEDS-LAYOUT NEEDS-PAINT
...          parentData: offset=Offset(0.0, 0.0); flex=null; fit=null
...          constraints: MISSING
...          size: MISSING
...          additionalConstraints: BoxConstraints(w=16.0, 0.0<=h<=Infinity)
...        child 3: RenderSemanticsAnnotations#0f483 NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...          parentData: offset=Offset(0.0, 0.0); flex=2; fit=FlexFit.tight
...          constraints: MISSING
...          semantic boundary
...          size: MISSING
====================================================================================================

======== Exception caught by rendering library =====================================================
The following assertion was thrown during performLayout():
RenderBox was not laid out: RenderFlex#1afc8 relayoutBoundary=up3 NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
'package:flutter/src/rendering/box.dart':
Failed assertion: line 2251 pos 12: 'hasSize'


Either the assertion indicates an error in the framework itself, or we should provide substantially more information in this error message to help you determine and fix the underlying cause.
In either case, please report this assertion by filing a bug on GitHub:
  https://github.com/flutter/flutter/issues/new?template=2_bug.yml

The relevant error-causing widget was: 
  Column Column:file:///Users/iqbalmahamud/classmate/lib/views/class_details_student/class_details_student_view.dart:519:14
When the exception was thrown, this was the stack: 
#2      RenderBox.size (package:flutter/src/rendering/box.dart:2251:12)
#3      ChildLayoutHelper.layoutChild (package:flutter/src/rendering/layout_helper.dart:63:18)
#4      RenderFlex._computeSizes (package:flutter/src/rendering/flex.dart:1161:28)
#5      RenderFlex.performLayout (package:flutter/src/rendering/flex.dart:1255:32)
#6      RenderObject.layout (package:flutter/src/rendering/object.dart:2715:7)
#7      RenderPadding.performLayout (package:flutter/src/rendering/shifted_box.dart:243:12)
#8      RenderObject.layout (package:flutter/src/rendering/object.dart:2715:7)
#9      _RenderSingleChildViewport.performLayout (package:flutter/src/widgets/single_child_scroll_view.dart:493:14)
#10     RenderObject._layoutWithoutResize (package:flutter/src/rendering/object.dart:2548:7)
#11     PipelineOwner.flushLayout (package:flutter/src/rendering/object.dart:1112:18)
#12     PipelineOwner.flushLayout (package:flutter/src/rendering/object.dart:1125:15)
#13     RendererBinding.drawFrame (package:flutter/src/rendering/binding.dart:616:23)
#14     WidgetsBinding.drawFrame (package:flutter/src/widgets/binding.dart:1231:13)
#15     RendererBinding._handlePersistentFrameCallback (package:flutter/src/rendering/binding.dart:482:5)
#16     SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1442:15)
#17     SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1355:9)
#18     SchedulerBinding._handleDrawFrame (package:flutter/src/scheduler/binding.dart:1208:5)
#19     _invoke (dart:ui/hooks.dart:316:13)
#20     PlatformDispatcher._drawFrame (dart:ui/platform_dispatcher.dart:428:5)
#21     _drawFrame (dart:ui/hooks.dart:288:31)
(elided 2 frames from class _AssertionError)
The following RenderObject was being processed when the exception was fired: RenderFlex#b4e94 relayoutBoundary=up2 NEEDS-LAYOUT NEEDS-COMPOSITING-BITS-UPDATE
...  parentData: offset=Offset(16.0, 0.0) (can use size)
...  constraints: BoxConstraints(w=370.0, 0.0<=h<=Infinity)
...  size: Size(370.0, 71.0)
...  direction: vertical
...  mainAxisAlignment: start
...  mainAxisSize: max
...  crossAxisAlignment: start
...  textDirection: ltr
...  verticalDirection: down
...  spacing: 0.0
RenderObject: RenderFlex#b4e94 relayoutBoundary=up2 NEEDS-LAYOUT NEEDS-COMPOSITING-BITS-UPDATE
  parentData: offset=Offset(16.0, 0.0) (can use size)
  constraints: BoxConstraints(w=370.0, 0.0<=h<=Infinity)
  size: Size(370.0, 71.0)
  direction: vertical
  mainAxisAlignment: start
  mainAxisSize: max
  crossAxisAlignment: start
  textDirection: ltr
  verticalDirection: down
  spacing: 0.0
...  child 1: RenderParagraph#cde41 relayoutBoundary=up3
...    parentData: offset=Offset(0.0, 0.0); flex=null; fit=null (can use size)
...    constraints: BoxConstraints(0.0<=w<=370.0, 0.0<=h<=Infinity)
...    semantics node: SemanticsNode#72
...      Rect.fromLTRB(16.0, 0.0, 81.6, 19.0)
...      label: "Quizzes"
...      textDirection: ltr
...    size: Size(65.6, 19.0)
...    textAlign: start
...    textDirection: ltr
...    softWrap: wrapping at box width
...    overflow: clip
...    locale: en_US
...    maxLines: unlimited
...    text: TextSpan
...      debugLabel: ((englishLike bodyMedium 2021).merge((blackCupertino bodyMedium).apply)).merge(unknown)
...      inherit: false
...      color: Color(alpha: 1.0000, red: 0.1137, green: 0.1059, blue: 0.1255, colorSpace: ColorSpace.sRGB)
...      family: CupertinoSystemText
...      size: 16.0
...      weight: 700
...      letterSpacing: 0.3
...      baseline: alphabetic
...      height: 1.2x
...      leadingDistribution: even
...      decoration: Color(alpha: 1.0000, red: 0.1137, green: 0.1059, blue: 0.1255, colorSpace: ColorSpace.sRGB) TextDecoration.none
...      "Quizzes"
...  child 2: RenderConstrainedBox#62c18 relayoutBoundary=up3
...    parentData: offset=Offset(0.0, 19.0); flex=null; fit=null (can use size)
...    constraints: BoxConstraints(0.0<=w<=370.0, 0.0<=h<=Infinity)
...    size: Size(0.0, 16.0)
...    additionalConstraints: BoxConstraints(0.0<=w<=Infinity, h=16.0)
...  child 3: RenderFlex#1afc8 relayoutBoundary=up3 NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...    parentData: offset=Offset(0.0, 0.0); flex=null; fit=null (can use size)
...    constraints: BoxConstraints(0.0<=w<=370.0, 0.0<=h<=Infinity)
...    size: MISSING
...    direction: vertical
...    mainAxisAlignment: start
...    mainAxisSize: max
...    crossAxisAlignment: center
...    verticalDirection: down
...    spacing: 0.0
...    child 1: RenderPadding#64a2b NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...      parentData: offset=Offset(0.0, 0.0); flex=null; fit=null
...      constraints: MISSING
...      size: MISSING
...      padding: EdgeInsets.all(16.0)
...      textDirection: ltr
...      child: RenderDecoratedBox#ac62e NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...        parentData: offset=Offset(0.0, 0.0)
...        constraints: MISSING
...        size: MISSING
...        decoration: BoxDecoration
...          color: Color(alpha: 1.0000, red: 0.8902, green: 0.9490, blue: 0.9922, colorSpace: ColorSpace.sRGB)
...          border: Border.all(BorderSide(color: Color(alpha: 1.0000, red: 0.5647, green: 0.7922, blue: 0.9765, colorSpace: ColorSpace.sRGB)))
...          borderRadius: BorderRadius.circular(12.0)
...        configuration: ImageConfiguration(bundle: PlatformAssetBundle#95326(), devicePixelRatio: 3.0, locale: en_US, textDirection: TextDirection.ltr, platform: iOS)
...        child: RenderPadding#05862 NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...          parentData: <none>
...          constraints: MISSING
...          size: MISSING
...          padding: EdgeInsets.all(17.0)
...          textDirection: ltr
...    child 2: RenderConstrainedBox#cbde9 NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...      parentData: offset=Offset(0.0, 0.0); flex=1; fit=FlexFit.loose
...      constraints: MISSING
...      size: MISSING
...      additionalConstraints: BoxConstraints(0.0<=w<=Infinity, h=524.4)
...      child: RenderPadding#1ccfe NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...        parentData: <none>
...        constraints: MISSING
...        size: MISSING
...        padding: EdgeInsets(16.0, 0.0, 16.0, 0.0)
...        textDirection: ltr
...        child: _RenderScrollSemantics#7b9f3 NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...          parentData: offset=Offset(0.0, 0.0)
...          constraints: MISSING
...          semantic boundary
...          size: MISSING
...    child 3: RenderConstrainedBox#cb168 NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...      parentData: offset=Offset(0.0, 0.0); flex=null; fit=null
...      constraints: MISSING
...      size: MISSING
...      additionalConstraints: BoxConstraints(w=Infinity, 0.0<=h<=Infinity)
...      child: RenderPadding#824fd NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...        parentData: <none>
...        constraints: MISSING
...        size: MISSING
...        padding: EdgeInsets.all(16.0)
...        textDirection: ltr
...        child: RenderFlex#288e5 NEEDS-LAYOUT NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE
...          parentData: offset=Offset(0.0, 0.0)
...          constraints: MISSING
...          size: MISSING
...          direction: horizontal
...          mainAxisAlignment: start
...          mainAxisSize: max
...          crossAxisAlignment: center
...          textDirection: ltr
...          verticalDirection: down
...          spacing: 0.0
====================================================================================================

======== Exception caught by scheduler library =====================================================
The following assertion was thrown during a scheduler callback:
Updated layout information required for RenderPadding#64a2b NEEDS-LAYOUT NEEDS-PAINT to calculate semantics.
'package:flutter/src/rendering/object.dart':
Failed assertion: line 3848 pos 12: '!_needsLayout'


Either the assertion indicates an error in the framework itself, or we should provide substantially more information in this error message to help you determine and fix the underlying cause.
In either case, please report this assertion by filing a bug on GitHub:
  https://github.com/flutter/flutter/issues/new?template=2_bug.yml

When the exception was thrown, this was the stack: 
#2      RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3848:12)
#3      RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#4      ContainerRenderObjectMixin.visitChildren (package:flutter/src/rendering/object.dart:4641:14)
#5      RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#6      RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#7      RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#8      ContainerRenderObjectMixin.visitChildren (package:flutter/src/rendering/object.dart:4641:14)
#9      RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#10     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#11     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#12     RenderObjectWithChildMixin.visitChildren (package:flutter/src/rendering/object.dart:4325:14)
#13     RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#14     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#15     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#16     RenderObjectWithChildMixin.visitChildren (package:flutter/src/rendering/object.dart:4325:14)
#17     RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#18     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#19     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#20     RenderObjectWithChildMixin.visitChildren (package:flutter/src/rendering/object.dart:4325:14)
#21     RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#22     RenderIgnorePointer.visitChildrenForSemantics (package:flutter/src/rendering/proxy_box.dart:3633:11)
#23     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#24     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#25     RenderObjectWithChildMixin.visitChildren (package:flutter/src/rendering/object.dart:4325:14)
#26     RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#27     RenderSemanticsAnnotations.visitChildrenForSemantics (package:flutter/src/rendering/proxy_box.dart:4300:11)
#28     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#29     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#30     RenderObjectWithChildMixin.visitChildren (package:flutter/src/rendering/object.dart:4325:14)
#31     RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#32     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#33     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#34     RenderObjectWithChildMixin.visitChildren (package:flutter/src/rendering/object.dart:4325:14)
#35     RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#36     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#37     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#38     RenderObjectWithChildMixin.visitChildren (package:flutter/src/rendering/object.dart:4325:14)
#39     RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#40     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#41     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#42     RenderObjectWithChildMixin.visitChildren (package:flutter/src/rendering/object.dart:4325:14)
#43     RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#44     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#45     RenderObject._updateSemantics (package:flutter/src/rendering/object.dart:3811:41)
#46     PipelineOwner.flushSemantics (package:flutter/src/rendering/object.dart:1378:16)
#47     PipelineOwner.flushSemantics (package:flutter/src/rendering/object.dart:1383:15)
#48     RendererBinding.drawFrame (package:flutter/src/rendering/binding.dart:623:25)
#49     WidgetsBinding.drawFrame (package:flutter/src/widgets/binding.dart:1231:13)
#50     RendererBinding._handlePersistentFrameCallback (package:flutter/src/rendering/binding.dart:482:5)
#51     SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1442:15)
#52     SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1355:9)
#53     SchedulerBinding._handleDrawFrame (package:flutter/src/scheduler/binding.dart:1208:5)
#54     _invoke (dart:ui/hooks.dart:316:13)
#55     PlatformDispatcher._drawFrame (dart:ui/platform_dispatcher.dart:428:5)
#56     _drawFrame (dart:ui/hooks.dart:288:31)
(elided 2 frames from class _AssertionError)
====================================================================================================

======== Exception caught by scheduler library =====================================================
The following assertion was thrown during a scheduler callback:
Updated layout information required for RenderPadding#64a2b NEEDS-LAYOUT NEEDS-PAINT to calculate semantics.
'package:flutter/src/rendering/object.dart':
Failed assertion: line 3848 pos 12: '!_needsLayout'


Either the assertion indicates an error in the framework itself, or we should provide substantially more information in this error message to help you determine and fix the underlying cause.
In either case, please report this assertion by filing a bug on GitHub:
  https://github.com/flutter/flutter/issues/new?template=2_bug.yml

When the exception was thrown, this was the stack: 
#2      RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3848:12)
#3      RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#4      ContainerRenderObjectMixin.visitChildren (package:flutter/src/rendering/object.dart:4641:14)
#5      RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#6      RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#7      RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#8      ContainerRenderObjectMixin.visitChildren (package:flutter/src/rendering/object.dart:4641:14)
#9      RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#10     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#11     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#12     RenderObjectWithChildMixin.visitChildren (package:flutter/src/rendering/object.dart:4325:14)
#13     RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#14     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#15     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#16     RenderObjectWithChildMixin.visitChildren (package:flutter/src/rendering/object.dart:4325:14)
#17     RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#18     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#19     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#20     RenderObjectWithChildMixin.visitChildren (package:flutter/src/rendering/object.dart:4325:14)
#21     RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#22     RenderIgnorePointer.visitChildrenForSemantics (package:flutter/src/rendering/proxy_box.dart:3633:11)
#23     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#24     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#25     RenderObjectWithChildMixin.visitChildren (package:flutter/src/rendering/object.dart:4325:14)
#26     RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#27     RenderSemanticsAnnotations.visitChildrenForSemantics (package:flutter/src/rendering/proxy_box.dart:4300:11)
#28     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#29     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#30     RenderObjectWithChildMixin.visitChildren (package:flutter/src/rendering/object.dart:4325:14)
#31     RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#32     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#33     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#34     RenderObjectWithChildMixin.visitChildren (package:flutter/src/rendering/object.dart:4325:14)
#35     RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#36     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#37     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#38     RenderObjectWithChildMixin.visitChildren (package:flutter/src/rendering/object.dart:4325:14)
#39     RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#40     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#41     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#42     RenderObjectWithChildMixin.visitChildren (package:flutter/src/rendering/object.dart:4325:14)
#43     RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#44     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#45     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#46     RenderObjectWithChildMixin.visitChildren (package:flutter/src/rendering/object.dart:4325:14)
#47     RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#48     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#49     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#50     Iterable.forEach (dart:core/iterable.dart:348:35)
#51     RenderViewportBase.visitChildrenForSemantics (package:flutter/src/rendering/viewport.dart:319:10)
#52     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#53     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#54     RenderObjectWithChildMixin.visitChildren (package:flutter/src/rendering/object.dart:4325:14)
#55     RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#56     RenderIgnorePointer.visitChildrenForSemantics (package:flutter/src/rendering/proxy_box.dart:3633:11)
#57     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#58     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#59     RenderObjectWithChildMixin.visitChildren (package:flutter/src/rendering/object.dart:4325:14)
#60     RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#61     RenderSemanticsAnnotations.visitChildrenForSemantics (package:flutter/src/rendering/proxy_box.dart:4300:11)
#62     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#63     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#64     RenderObjectWithChildMixin.visitChildren (package:flutter/src/rendering/object.dart:4325:14)
#65     RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#66     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#67     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#68     RenderObjectWithChildMixin.visitChildren (package:flutter/src/rendering/object.dart:4325:14)
#69     RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#70     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#71     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#72     RenderObjectWithChildMixin.visitChildren (package:flutter/src/rendering/object.dart:4325:14)
#73     RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#74     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#75     RenderObject._getSemanticsForParent.<anonymous closure> (package:flutter/src/rendering/object.dart:3867:61)
#76     RenderObjectWithChildMixin.visitChildren (package:flutter/src/rendering/object.dart:4325:14)
#77     RenderObject.visitChildrenForSemantics (package:flutter/src/rendering/object.dart:4015:5)
#78     RenderObject._getSemanticsForParent (package:flutter/src/rendering/object.dart:3865:5)
#79     RenderObject._updateSemantics (package:flutter/src/rendering/object.dart:3811:41)
#80     PipelineOwner.flushSemantics (package:flutter/src/rendering/object.dart:1378:16)
#81     PipelineOwner.flushSemantics (package:flutter/src/rendering/object.dart:1383:15)
#82     RendererBinding.drawFrame (package:flutter/src/rendering/binding.dart:623:25)
#83     WidgetsBinding.drawFrame (package:flutter/src/widgets/binding.dart:1231:13)
#84     RendererBinding._handlePersistentFrameCallback (package:flutter/src/rendering/binding.dart:482:5)
#85     SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1442:15)
#86     SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1355:9)
#87     SchedulerBinding._handleDrawFrame (package:flutter/src/scheduler/binding.dart:1208:5)
#88     _invoke (dart:ui/hooks.dart:316:13)
#89     PlatformDispatcher._drawFrame (dart:ui/platform_dispatcher.dart:428:5)
#90     _drawFrame (dart:ui/hooks.dart:288:31)
(elided 2 frames from class _AssertionError)
====================================================================================================
flutter: 🔄 Periodic session check for course: 688c897cbc0e48abbbd88fc7
