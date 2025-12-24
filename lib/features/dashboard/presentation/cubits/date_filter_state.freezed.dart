// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'date_filter_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DateFilterState {

/// The currently selected date for filtering.
///
/// Used to filter transactions and display in the date picker.
/// Should be normalized to start of day (00:00:00) for accurate comparison.
///
/// **Default**: Today's date
 DateTime get selectedDate;/// Transactions that occurred on the selected date.
///
/// **Denormalized**: Each [TransactionVModel] includes:
/// - Transaction data (name, amount, type, date)
/// - Category data (name, icon)
/// - Formatted date string
///
/// **Sorted**: Newest to oldest by transaction time
///
/// **Empty List**: Valid state when no transactions exist for selected date
 List<TransactionVModel> get filteredTransactions;
/// Create a copy of DateFilterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DateFilterStateCopyWith<DateFilterState> get copyWith => _$DateFilterStateCopyWithImpl<DateFilterState>(this as DateFilterState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DateFilterState&&(identical(other.selectedDate, selectedDate) || other.selectedDate == selectedDate)&&const DeepCollectionEquality().equals(other.filteredTransactions, filteredTransactions));
}


@override
int get hashCode => Object.hash(runtimeType,selectedDate,const DeepCollectionEquality().hash(filteredTransactions));

@override
String toString() {
  return 'DateFilterState(selectedDate: $selectedDate, filteredTransactions: $filteredTransactions)';
}


}

/// @nodoc
abstract mixin class $DateFilterStateCopyWith<$Res>  {
  factory $DateFilterStateCopyWith(DateFilterState value, $Res Function(DateFilterState) _then) = _$DateFilterStateCopyWithImpl;
@useResult
$Res call({
 DateTime selectedDate, List<TransactionVModel> filteredTransactions
});




}
/// @nodoc
class _$DateFilterStateCopyWithImpl<$Res>
    implements $DateFilterStateCopyWith<$Res> {
  _$DateFilterStateCopyWithImpl(this._self, this._then);

  final DateFilterState _self;
  final $Res Function(DateFilterState) _then;

/// Create a copy of DateFilterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedDate = null,Object? filteredTransactions = null,}) {
  return _then(_self.copyWith(
selectedDate: null == selectedDate ? _self.selectedDate : selectedDate // ignore: cast_nullable_to_non_nullable
as DateTime,filteredTransactions: null == filteredTransactions ? _self.filteredTransactions : filteredTransactions // ignore: cast_nullable_to_non_nullable
as List<TransactionVModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [DateFilterState].
extension DateFilterStatePatterns on DateFilterState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DateFilterState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DateFilterState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DateFilterState value)  $default,){
final _that = this;
switch (_that) {
case _DateFilterState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DateFilterState value)?  $default,){
final _that = this;
switch (_that) {
case _DateFilterState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime selectedDate,  List<TransactionVModel> filteredTransactions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DateFilterState() when $default != null:
return $default(_that.selectedDate,_that.filteredTransactions);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime selectedDate,  List<TransactionVModel> filteredTransactions)  $default,) {final _that = this;
switch (_that) {
case _DateFilterState():
return $default(_that.selectedDate,_that.filteredTransactions);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime selectedDate,  List<TransactionVModel> filteredTransactions)?  $default,) {final _that = this;
switch (_that) {
case _DateFilterState() when $default != null:
return $default(_that.selectedDate,_that.filteredTransactions);case _:
  return null;

}
}

}

/// @nodoc


class _DateFilterState implements DateFilterState {
  const _DateFilterState({required this.selectedDate, required final  List<TransactionVModel> filteredTransactions}): _filteredTransactions = filteredTransactions;
  

/// The currently selected date for filtering.
///
/// Used to filter transactions and display in the date picker.
/// Should be normalized to start of day (00:00:00) for accurate comparison.
///
/// **Default**: Today's date
@override final  DateTime selectedDate;
/// Transactions that occurred on the selected date.
///
/// **Denormalized**: Each [TransactionVModel] includes:
/// - Transaction data (name, amount, type, date)
/// - Category data (name, icon)
/// - Formatted date string
///
/// **Sorted**: Newest to oldest by transaction time
///
/// **Empty List**: Valid state when no transactions exist for selected date
 final  List<TransactionVModel> _filteredTransactions;
/// Transactions that occurred on the selected date.
///
/// **Denormalized**: Each [TransactionVModel] includes:
/// - Transaction data (name, amount, type, date)
/// - Category data (name, icon)
/// - Formatted date string
///
/// **Sorted**: Newest to oldest by transaction time
///
/// **Empty List**: Valid state when no transactions exist for selected date
@override List<TransactionVModel> get filteredTransactions {
  if (_filteredTransactions is EqualUnmodifiableListView) return _filteredTransactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_filteredTransactions);
}


/// Create a copy of DateFilterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DateFilterStateCopyWith<_DateFilterState> get copyWith => __$DateFilterStateCopyWithImpl<_DateFilterState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DateFilterState&&(identical(other.selectedDate, selectedDate) || other.selectedDate == selectedDate)&&const DeepCollectionEquality().equals(other._filteredTransactions, _filteredTransactions));
}


@override
int get hashCode => Object.hash(runtimeType,selectedDate,const DeepCollectionEquality().hash(_filteredTransactions));

@override
String toString() {
  return 'DateFilterState(selectedDate: $selectedDate, filteredTransactions: $filteredTransactions)';
}


}

/// @nodoc
abstract mixin class _$DateFilterStateCopyWith<$Res> implements $DateFilterStateCopyWith<$Res> {
  factory _$DateFilterStateCopyWith(_DateFilterState value, $Res Function(_DateFilterState) _then) = __$DateFilterStateCopyWithImpl;
@override @useResult
$Res call({
 DateTime selectedDate, List<TransactionVModel> filteredTransactions
});




}
/// @nodoc
class __$DateFilterStateCopyWithImpl<$Res>
    implements _$DateFilterStateCopyWith<$Res> {
  __$DateFilterStateCopyWithImpl(this._self, this._then);

  final _DateFilterState _self;
  final $Res Function(_DateFilterState) _then;

/// Create a copy of DateFilterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedDate = null,Object? filteredTransactions = null,}) {
  return _then(_DateFilterState(
selectedDate: null == selectedDate ? _self.selectedDate : selectedDate // ignore: cast_nullable_to_non_nullable
as DateTime,filteredTransactions: null == filteredTransactions ? _self._filteredTransactions : filteredTransactions // ignore: cast_nullable_to_non_nullable
as List<TransactionVModel>,
  ));
}


}

// dart format on
