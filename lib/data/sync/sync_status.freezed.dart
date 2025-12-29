// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SyncStatus {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncStatus);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SyncStatus()';
}


}

/// @nodoc
class $SyncStatusCopyWith<$Res>  {
$SyncStatusCopyWith(SyncStatus _, $Res Function(SyncStatus) __);
}


/// Adds pattern-matching-related methods to [SyncStatus].
extension SyncStatusPatterns on SyncStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Idle value)?  idle,TResult Function( _Syncing value)?  syncing,TResult Function( _Synced value)?  synced,TResult Function( _Failed value)?  failed,TResult Function( _Offline value)?  offline,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle(_that);case _Syncing() when syncing != null:
return syncing(_that);case _Synced() when synced != null:
return synced(_that);case _Failed() when failed != null:
return failed(_that);case _Offline() when offline != null:
return offline(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Idle value)  idle,required TResult Function( _Syncing value)  syncing,required TResult Function( _Synced value)  synced,required TResult Function( _Failed value)  failed,required TResult Function( _Offline value)  offline,}){
final _that = this;
switch (_that) {
case _Idle():
return idle(_that);case _Syncing():
return syncing(_that);case _Synced():
return synced(_that);case _Failed():
return failed(_that);case _Offline():
return offline(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Idle value)?  idle,TResult? Function( _Syncing value)?  syncing,TResult? Function( _Synced value)?  synced,TResult? Function( _Failed value)?  failed,TResult? Function( _Offline value)?  offline,}){
final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle(_that);case _Syncing() when syncing != null:
return syncing(_that);case _Synced() when synced != null:
return synced(_that);case _Failed() when failed != null:
return failed(_that);case _Offline() when offline != null:
return offline(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  syncing,TResult Function( DateTime lastSyncTime)?  synced,TResult Function( String error)?  failed,TResult Function()?  offline,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle();case _Syncing() when syncing != null:
return syncing();case _Synced() when synced != null:
return synced(_that.lastSyncTime);case _Failed() when failed != null:
return failed(_that.error);case _Offline() when offline != null:
return offline();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  syncing,required TResult Function( DateTime lastSyncTime)  synced,required TResult Function( String error)  failed,required TResult Function()  offline,}) {final _that = this;
switch (_that) {
case _Idle():
return idle();case _Syncing():
return syncing();case _Synced():
return synced(_that.lastSyncTime);case _Failed():
return failed(_that.error);case _Offline():
return offline();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  syncing,TResult? Function( DateTime lastSyncTime)?  synced,TResult? Function( String error)?  failed,TResult? Function()?  offline,}) {final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle();case _Syncing() when syncing != null:
return syncing();case _Synced() when synced != null:
return synced(_that.lastSyncTime);case _Failed() when failed != null:
return failed(_that.error);case _Offline() when offline != null:
return offline();case _:
  return null;

}
}

}

/// @nodoc


class _Idle implements SyncStatus {
  const _Idle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Idle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SyncStatus.idle()';
}


}




/// @nodoc


class _Syncing implements SyncStatus {
  const _Syncing();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Syncing);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SyncStatus.syncing()';
}


}




/// @nodoc


class _Synced implements SyncStatus {
  const _Synced({required this.lastSyncTime});
  

 final  DateTime lastSyncTime;

/// Create a copy of SyncStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncedCopyWith<_Synced> get copyWith => __$SyncedCopyWithImpl<_Synced>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Synced&&(identical(other.lastSyncTime, lastSyncTime) || other.lastSyncTime == lastSyncTime));
}


@override
int get hashCode => Object.hash(runtimeType,lastSyncTime);

@override
String toString() {
  return 'SyncStatus.synced(lastSyncTime: $lastSyncTime)';
}


}

/// @nodoc
abstract mixin class _$SyncedCopyWith<$Res> implements $SyncStatusCopyWith<$Res> {
  factory _$SyncedCopyWith(_Synced value, $Res Function(_Synced) _then) = __$SyncedCopyWithImpl;
@useResult
$Res call({
 DateTime lastSyncTime
});




}
/// @nodoc
class __$SyncedCopyWithImpl<$Res>
    implements _$SyncedCopyWith<$Res> {
  __$SyncedCopyWithImpl(this._self, this._then);

  final _Synced _self;
  final $Res Function(_Synced) _then;

/// Create a copy of SyncStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? lastSyncTime = null,}) {
  return _then(_Synced(
lastSyncTime: null == lastSyncTime ? _self.lastSyncTime : lastSyncTime // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class _Failed implements SyncStatus {
  const _Failed({required this.error});
  

 final  String error;

/// Create a copy of SyncStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FailedCopyWith<_Failed> get copyWith => __$FailedCopyWithImpl<_Failed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Failed&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'SyncStatus.failed(error: $error)';
}


}

/// @nodoc
abstract mixin class _$FailedCopyWith<$Res> implements $SyncStatusCopyWith<$Res> {
  factory _$FailedCopyWith(_Failed value, $Res Function(_Failed) _then) = __$FailedCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class __$FailedCopyWithImpl<$Res>
    implements _$FailedCopyWith<$Res> {
  __$FailedCopyWithImpl(this._self, this._then);

  final _Failed _self;
  final $Res Function(_Failed) _then;

/// Create a copy of SyncStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_Failed(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Offline implements SyncStatus {
  const _Offline();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Offline);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SyncStatus.offline()';
}


}




// dart format on
