// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'allocation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AllocationModel {

/// Unique identifier (UUID v4)
 String get id;/// Amount allocated to this category in this budget
///
/// Should be positive and typically less than the budget's total amount.
/// Multiple allocations for the same budget should sum to <= budget.amount.
 double get amount;/// Reference to the category receiving this allocation
///
/// Links to [CategoryModel.id].
 String get categoryId;/// Reference to the parent budget
///
/// Links to [BudgetModel.id].
 String get budgetId;/// Timestamp when allocation was created
 DateTime get createdAt;/// Timestamp when allocation was last modified
 DateTime get updatedAt;
/// Create a copy of AllocationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AllocationModelCopyWith<AllocationModel> get copyWith => _$AllocationModelCopyWithImpl<AllocationModel>(this as AllocationModel, _$identity);

  /// Serializes this AllocationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AllocationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.budgetId, budgetId) || other.budgetId == budgetId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,amount,categoryId,budgetId,createdAt,updatedAt);

@override
String toString() {
  return 'AllocationModel(id: $id, amount: $amount, categoryId: $categoryId, budgetId: $budgetId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AllocationModelCopyWith<$Res>  {
  factory $AllocationModelCopyWith(AllocationModel value, $Res Function(AllocationModel) _then) = _$AllocationModelCopyWithImpl;
@useResult
$Res call({
 String id, double amount, String categoryId, String budgetId, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$AllocationModelCopyWithImpl<$Res>
    implements $AllocationModelCopyWith<$Res> {
  _$AllocationModelCopyWithImpl(this._self, this._then);

  final AllocationModel _self;
  final $Res Function(AllocationModel) _then;

/// Create a copy of AllocationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? amount = null,Object? categoryId = null,Object? budgetId = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,budgetId: null == budgetId ? _self.budgetId : budgetId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AllocationModel].
extension AllocationModelPatterns on AllocationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AllocationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AllocationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AllocationModel value)  $default,){
final _that = this;
switch (_that) {
case _AllocationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AllocationModel value)?  $default,){
final _that = this;
switch (_that) {
case _AllocationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double amount,  String categoryId,  String budgetId,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AllocationModel() when $default != null:
return $default(_that.id,_that.amount,_that.categoryId,_that.budgetId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double amount,  String categoryId,  String budgetId,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AllocationModel():
return $default(_that.id,_that.amount,_that.categoryId,_that.budgetId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double amount,  String categoryId,  String budgetId,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AllocationModel() when $default != null:
return $default(_that.id,_that.amount,_that.categoryId,_that.budgetId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AllocationModel implements AllocationModel {
  const _AllocationModel({required this.id, required this.amount, required this.categoryId, required this.budgetId, required this.createdAt, required this.updatedAt});
  factory _AllocationModel.fromJson(Map<String, dynamic> json) => _$AllocationModelFromJson(json);

/// Unique identifier (UUID v4)
@override final  String id;
/// Amount allocated to this category in this budget
///
/// Should be positive and typically less than the budget's total amount.
/// Multiple allocations for the same budget should sum to <= budget.amount.
@override final  double amount;
/// Reference to the category receiving this allocation
///
/// Links to [CategoryModel.id].
@override final  String categoryId;
/// Reference to the parent budget
///
/// Links to [BudgetModel.id].
@override final  String budgetId;
/// Timestamp when allocation was created
@override final  DateTime createdAt;
/// Timestamp when allocation was last modified
@override final  DateTime updatedAt;

/// Create a copy of AllocationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AllocationModelCopyWith<_AllocationModel> get copyWith => __$AllocationModelCopyWithImpl<_AllocationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AllocationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AllocationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.budgetId, budgetId) || other.budgetId == budgetId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,amount,categoryId,budgetId,createdAt,updatedAt);

@override
String toString() {
  return 'AllocationModel(id: $id, amount: $amount, categoryId: $categoryId, budgetId: $budgetId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AllocationModelCopyWith<$Res> implements $AllocationModelCopyWith<$Res> {
  factory _$AllocationModelCopyWith(_AllocationModel value, $Res Function(_AllocationModel) _then) = __$AllocationModelCopyWithImpl;
@override @useResult
$Res call({
 String id, double amount, String categoryId, String budgetId, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$AllocationModelCopyWithImpl<$Res>
    implements _$AllocationModelCopyWith<$Res> {
  __$AllocationModelCopyWithImpl(this._self, this._then);

  final _AllocationModel _self;
  final $Res Function(_AllocationModel) _then;

/// Create a copy of AllocationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? amount = null,Object? categoryId = null,Object? budgetId = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_AllocationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,budgetId: null == budgetId ? _self.budgetId : budgetId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
