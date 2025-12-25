// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_v_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransactionVModel {

 String get id; String get name; double get amount; TransactionType get type; DateTime get transactionDate; String get formattedDate; String get formattedTime; String? get categoryId; String? get categoryName; String? get categoryIconName; String? get notes;
/// Create a copy of TransactionVModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionVModelCopyWith<TransactionVModel> get copyWith => _$TransactionVModelCopyWithImpl<TransactionVModel>(this as TransactionVModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionVModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.formattedDate, formattedDate) || other.formattedDate == formattedDate)&&(identical(other.formattedTime, formattedTime) || other.formattedTime == formattedTime)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.categoryIconName, categoryIconName) || other.categoryIconName == categoryIconName)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,amount,type,transactionDate,formattedDate,formattedTime,categoryId,categoryName,categoryIconName,notes);

@override
String toString() {
  return 'TransactionVModel(id: $id, name: $name, amount: $amount, type: $type, transactionDate: $transactionDate, formattedDate: $formattedDate, formattedTime: $formattedTime, categoryId: $categoryId, categoryName: $categoryName, categoryIconName: $categoryIconName, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $TransactionVModelCopyWith<$Res>  {
  factory $TransactionVModelCopyWith(TransactionVModel value, $Res Function(TransactionVModel) _then) = _$TransactionVModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, double amount, TransactionType type, DateTime transactionDate, String formattedDate, String formattedTime, String? categoryId, String? categoryName, String? categoryIconName, String? notes
});




}
/// @nodoc
class _$TransactionVModelCopyWithImpl<$Res>
    implements $TransactionVModelCopyWith<$Res> {
  _$TransactionVModelCopyWithImpl(this._self, this._then);

  final TransactionVModel _self;
  final $Res Function(TransactionVModel) _then;

/// Create a copy of TransactionVModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? amount = null,Object? type = null,Object? transactionDate = null,Object? formattedDate = null,Object? formattedTime = null,Object? categoryId = freezed,Object? categoryName = freezed,Object? categoryIconName = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as DateTime,formattedDate: null == formattedDate ? _self.formattedDate : formattedDate // ignore: cast_nullable_to_non_nullable
as String,formattedTime: null == formattedTime ? _self.formattedTime : formattedTime // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,categoryIconName: freezed == categoryIconName ? _self.categoryIconName : categoryIconName // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionVModel].
extension TransactionVModelPatterns on TransactionVModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionVModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionVModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionVModel value)  $default,){
final _that = this;
switch (_that) {
case _TransactionVModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionVModel value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionVModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double amount,  TransactionType type,  DateTime transactionDate,  String formattedDate,  String formattedTime,  String? categoryId,  String? categoryName,  String? categoryIconName,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionVModel() when $default != null:
return $default(_that.id,_that.name,_that.amount,_that.type,_that.transactionDate,_that.formattedDate,_that.formattedTime,_that.categoryId,_that.categoryName,_that.categoryIconName,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double amount,  TransactionType type,  DateTime transactionDate,  String formattedDate,  String formattedTime,  String? categoryId,  String? categoryName,  String? categoryIconName,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _TransactionVModel():
return $default(_that.id,_that.name,_that.amount,_that.type,_that.transactionDate,_that.formattedDate,_that.formattedTime,_that.categoryId,_that.categoryName,_that.categoryIconName,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double amount,  TransactionType type,  DateTime transactionDate,  String formattedDate,  String formattedTime,  String? categoryId,  String? categoryName,  String? categoryIconName,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _TransactionVModel() when $default != null:
return $default(_that.id,_that.name,_that.amount,_that.type,_that.transactionDate,_that.formattedDate,_that.formattedTime,_that.categoryId,_that.categoryName,_that.categoryIconName,_that.notes);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionVModel implements TransactionVModel {
  const _TransactionVModel({required this.id, required this.name, required this.amount, required this.type, required this.transactionDate, required this.formattedDate, required this.formattedTime, this.categoryId, this.categoryName, this.categoryIconName, this.notes});
  

@override final  String id;
@override final  String name;
@override final  double amount;
@override final  TransactionType type;
@override final  DateTime transactionDate;
@override final  String formattedDate;
@override final  String formattedTime;
@override final  String? categoryId;
@override final  String? categoryName;
@override final  String? categoryIconName;
@override final  String? notes;

/// Create a copy of TransactionVModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionVModelCopyWith<_TransactionVModel> get copyWith => __$TransactionVModelCopyWithImpl<_TransactionVModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionVModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.formattedDate, formattedDate) || other.formattedDate == formattedDate)&&(identical(other.formattedTime, formattedTime) || other.formattedTime == formattedTime)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.categoryIconName, categoryIconName) || other.categoryIconName == categoryIconName)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,amount,type,transactionDate,formattedDate,formattedTime,categoryId,categoryName,categoryIconName,notes);

@override
String toString() {
  return 'TransactionVModel(id: $id, name: $name, amount: $amount, type: $type, transactionDate: $transactionDate, formattedDate: $formattedDate, formattedTime: $formattedTime, categoryId: $categoryId, categoryName: $categoryName, categoryIconName: $categoryIconName, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$TransactionVModelCopyWith<$Res> implements $TransactionVModelCopyWith<$Res> {
  factory _$TransactionVModelCopyWith(_TransactionVModel value, $Res Function(_TransactionVModel) _then) = __$TransactionVModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double amount, TransactionType type, DateTime transactionDate, String formattedDate, String formattedTime, String? categoryId, String? categoryName, String? categoryIconName, String? notes
});




}
/// @nodoc
class __$TransactionVModelCopyWithImpl<$Res>
    implements _$TransactionVModelCopyWith<$Res> {
  __$TransactionVModelCopyWithImpl(this._self, this._then);

  final _TransactionVModel _self;
  final $Res Function(_TransactionVModel) _then;

/// Create a copy of TransactionVModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? amount = null,Object? type = null,Object? transactionDate = null,Object? formattedDate = null,Object? formattedTime = null,Object? categoryId = freezed,Object? categoryName = freezed,Object? categoryIconName = freezed,Object? notes = freezed,}) {
  return _then(_TransactionVModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as DateTime,formattedDate: null == formattedDate ? _self.formattedDate : formattedDate // ignore: cast_nullable_to_non_nullable
as String,formattedTime: null == formattedTime ? _self.formattedTime : formattedTime // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,categoryIconName: freezed == categoryIconName ? _self.categoryIconName : categoryIconName // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
