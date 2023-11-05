// NOTE: Assertions have been autogenerated by utils/generate-test-checks.py
// RUN: dynamatic-opt --handshake-optimize-bitwidths --remove-operation-names %s --split-input-file | FileCheck %s

// CHECK-LABEL:   handshake.func @cmergeToMuxIndexOpt(
// CHECK-SAME:                                        %[[VAL_0:.*]]: i32, %[[VAL_1:.*]]: i32,
// CHECK-SAME:                                        %[[VAL_2:.*]]: none, ...) -> (i32, i32) attributes {argNames = ["arg0", "arg1", "start"], resNames = ["out0", "out1"]} {
// CHECK:           %[[VAL_3:.*]], %[[VAL_4:.*]] = control_merge %[[VAL_0]], %[[VAL_1]] : i32, i1
// CHECK:           %[[VAL_5:.*]] = mux %[[VAL_4]] {{\[}}%[[VAL_0]], %[[VAL_1]]] : i1, i32
// CHECK:           %[[VAL_6:.*]]:2 = d_return %[[VAL_3]], %[[VAL_5]] : i32, i32
// CHECK:           end %[[VAL_6]]#0, %[[VAL_6]]#1 : i32, i32
// CHECK:         }
handshake.func @cmergeToMuxIndexOpt(%arg0: i32, %arg1: i32, %start: none) -> (i32, i32) {
  %result, %index = control_merge %arg0, %arg1 : i32, i32
  %mux = mux %index [%arg0, %arg1] : i32, i32
  %returnVals:2 = d_return %result, %mux : i32, i32
  end %returnVals#0, %returnVals#1 : i32, i32
}

// -----

// CHECK-LABEL:   handshake.func @cmergeToMuxIndexOpt(
// CHECK-SAME:                                        %[[VAL_0:.*]]: i32, %[[VAL_1:.*]]: i32,
// CHECK-SAME:                                        %[[VAL_2:.*]]: none, ...) -> i32 attributes {argNames = ["arg0", "arg1", "start"], resNames = ["out0"]} {
// CHECK:           %[[VAL_3:.*]] = merge %[[VAL_0]] : i32
// CHECK:           %[[VAL_4:.*]] = source
// CHECK:           %[[VAL_5:.*]] = constant %[[VAL_4]] {value = 0 : i0} : i0
// CHECK:           %[[VAL_6:.*]] = merge %[[VAL_1]] : i32
// CHECK:           %[[VAL_7:.*]] = arith.extui %[[VAL_5]] : i0 to i32
// CHECK:           %[[VAL_8:.*]] = arith.addi %[[VAL_6]], %[[VAL_7]] : i32
// CHECK:           %[[VAL_9:.*]] = arith.addi %[[VAL_8]], %[[VAL_3]] : i32
// CHECK:           %[[VAL_10:.*]] = d_return %[[VAL_9]] : i32
// CHECK:           end %[[VAL_10]] : i32
// CHECK:         }

handshake.func @cmergeToMuxIndexOpt(%arg0: i32, %arg1: i32, %start: none) -> i32 {
  %result, %index = control_merge %arg0 : i32, i32
  %mux = mux %index [%arg1] : i32, i32
  %otherResult, %otherIndex = control_merge %arg1 : i32, i32
  %add1 = arith.addi %otherResult, %otherIndex : i32
  %add2 = arith.addi %add1, %result : i32
  %ret = d_return %add2 : i32
  end %ret : i32
}

// -----

// CHECK-LABEL:   handshake.func @memAddrOpt(
// CHECK-SAME:                               %[[VAL_0:.*]]: memref<1000xi32>,
// CHECK-SAME:                               %[[VAL_1:.*]]: none, ...) -> i32 attributes {argNames = ["mem", "start"], resNames = ["out0"]} {
// CHECK:           %[[VAL_2:.*]], %[[VAL_3:.*]] = mem_controller{{\[}}%[[VAL_0]] : memref<1000xi32>] (%[[VAL_4:.*]], %[[VAL_5:.*]], %[[VAL_6:.*]], %[[VAL_7:.*]], %[[VAL_8:.*]], %[[VAL_9:.*]]) : (i32, i10, i10, i32, i10, i32) -> (i32, none)
// CHECK:           %[[VAL_10:.*]] = constant %[[VAL_1]] {value = 0 : i8} : i8
// CHECK:           %[[VAL_11:.*]] = arith.extui %[[VAL_10]] : i8 to i10
// CHECK:           %[[VAL_12:.*]] = constant %[[VAL_1]] {value = 500 : i16} : i16
// CHECK:           %[[VAL_13:.*]] = arith.trunci %[[VAL_12]] : i16 to i10
// CHECK:           %[[VAL_14:.*]] = constant %[[VAL_1]] {value = 999 : i32} : i32
// CHECK:           %[[VAL_15:.*]] = arith.trunci %[[VAL_14]] : i32 to i10
// CHECK:           %[[VAL_16:.*]] = constant %[[VAL_1]] {value = 42 : i32} : i32
// CHECK:           %[[VAL_4]] = constant %[[VAL_1]] {bb = 0 : ui32, value = 2 : i32} : i32
// CHECK:           %[[VAL_5]], %[[VAL_17:.*]] = d_load{{\[}}%[[VAL_11]]] %[[VAL_2]] {bb = 0 : ui32} : i10, i32
// CHECK:           %[[VAL_6]], %[[VAL_7]] = d_store{{\[}}%[[VAL_13]]] %[[VAL_16]] {bb = 0 : ui32} : i32, i10
// CHECK:           %[[VAL_8]], %[[VAL_9]] = d_store{{\[}}%[[VAL_15]]] %[[VAL_16]] {bb = 0 : ui32} : i32, i10
// CHECK:           %[[VAL_18:.*]] = d_return %[[VAL_17]] : i32
// CHECK:           end %[[VAL_18]], %[[VAL_3]] : i32, none
// CHECK:         }
handshake.func @memAddrOpt(%mem: memref<1000xi32>, %start: none) -> i32 {
  %ldData1, %done = mem_controller[%mem : memref<1000xi32>] (%ctrl1, %ldAddr1, %stAddr1, %stData1, %stAddr2, %stData2) : (i32, i32, i32, i32, i32, i32) -> (i32, none)
  %addr1 = handshake.constant %start {value = 0 : i8} : i8
  %addr2 = handshake.constant %start {value = 500 : i16}: i16
  %addr3 = handshake.constant %start {value = 999 : i32}: i32
  %dataStore = handshake.constant %start {value = 42 : i32}: i32
  %ctrl1 = handshake.constant %start {value = 2 : i32, bb = 0 : ui32}: i32
  %addr1Ext = arith.extui %addr1 : i8 to i32
  %addr2Ext = arith.extui %addr2 : i16 to i32
  %ldAddr1, %ldVal = d_load[%addr1Ext] %ldData1 {bb = 0 : ui32} : i32, i32
  %stAddr1, %stData1 = d_store[%addr2Ext] %dataStore {bb = 0 : ui32} : i32, i32
  %stAddr2, %stData2 = d_store[%addr3] %dataStore {bb = 0 : ui32} : i32, i32
  %returnVal = d_return %ldVal : i32
  end %returnVal, %done : i32, none
}

// -----

// CHECK-LABEL:   handshake.func @simpleCycle(
// CHECK-SAME:                                %[[VAL_0:.*]]: i8, %[[VAL_1:.*]]: i1, %[[VAL_2:.*]]: i1,
// CHECK-SAME:                                %[[VAL_3:.*]]: none, ...) -> i32 attributes {argNames = ["arg0", "index", "cond", "start"], resNames = ["out0"]} {
// CHECK:           %[[VAL_4:.*]] = mux %[[VAL_1]] {{\[}}%[[VAL_0]], %[[VAL_5:.*]]] : i1, i8
// CHECK:           %[[VAL_5]], %[[VAL_6:.*]] = cond_br %[[VAL_2]], %[[VAL_4]] : i8
// CHECK:           %[[VAL_7:.*]] = arith.extsi %[[VAL_6]] : i8 to i32
// CHECK:           %[[VAL_8:.*]] = d_return %[[VAL_7]] : i32
// CHECK:           end %[[VAL_8]] : i32
// CHECK:         }
handshake.func @simpleCycle(%arg0: i8, %index: i1, %cond: i1, %start: none) -> i32 {
  %ext = arith.extsi %arg0 : i8 to i32
  %muxOut = mux %index [%ext, %true] : i1, i32
  %true, %false = cond_br %cond, %muxOut : i32
  %returnVal = d_return %false : i32
  end %returnVal : i32
}

// -----

// CHECK-LABEL:   handshake.func @complexCycle(
// CHECK-SAME:                                 %[[VAL_0:.*]]: i8, %[[VAL_1:.*]]: i16, %[[VAL_2:.*]]: i24, %[[VAL_3:.*]]: i2, %[[VAL_4:.*]]: i1, %[[VAL_5:.*]]: i1,
// CHECK-SAME:                                 %[[VAL_6:.*]]: none, ...) -> i32 attributes {argNames = ["arg0", "arg1", "arg2", "bigIndex", "index", "cond", "start"], resNames = ["out0"]} {
// CHECK:           %[[VAL_7:.*]] = arith.extsi %[[VAL_0]] {bb = 0 : ui32} : i8 to i24
// CHECK:           %[[VAL_8:.*]] = arith.extsi %[[VAL_1]] {bb = 0 : ui32} : i16 to i24
// CHECK:           %[[VAL_9:.*]] = mux %[[VAL_3]] {{\[}}%[[VAL_7]], %[[VAL_10:.*]], %[[VAL_11:.*]], %[[VAL_12:.*]]] : i2, i24
// CHECK:           %[[VAL_10]], %[[VAL_13:.*]] = cond_br %[[VAL_5]], %[[VAL_9]] : i24
// CHECK:           %[[VAL_14:.*]] = mux %[[VAL_4]] {{\[}}%[[VAL_8]], %[[VAL_13]]] : i1, i24
// CHECK:           %[[VAL_11]], %[[VAL_15:.*]] = cond_br %[[VAL_5]], %[[VAL_14]] : i24
// CHECK:           %[[VAL_16:.*]] = mux %[[VAL_4]] {{\[}}%[[VAL_2]], %[[VAL_15]]] : i1, i24
// CHECK:           %[[VAL_12]], %[[VAL_17:.*]] = cond_br %[[VAL_5]], %[[VAL_16]] : i24
// CHECK:           %[[VAL_18:.*]] = arith.extsi %[[VAL_17]] : i24 to i32
// CHECK:           %[[VAL_19:.*]] = d_return %[[VAL_18]] : i32
// CHECK:           end %[[VAL_19]] : i32
// CHECK:         }
handshake.func @complexCycle(%arg0: i8, %arg1: i16, %arg2: i24, %bigIndex: i2, %index: i1, %cond: i1, %start: none) -> i32 {
  %ext0 = arith.extsi %arg0 : i8 to i32
  %ext1 = arith.extsi %arg1 : i16 to i32
  %ext2 = arith.extsi %arg2 : i24 to i32
  %mux0 = mux %bigIndex [%ext0, %condTrue0, %condTrue1, %condTrue2] : i2, i32
  %condTrue0, %condFalse0 = cond_br %cond, %mux0 : i32
  %mux1 = mux %index [%ext1, %condFalse0] : i1, i32
  %condTrue1, %condFalse1 = cond_br %cond, %mux1 : i32
  %mux2 = mux %index [%ext2, %condFalse1] : i1, i32
  %condTrue2, %condFalse2 = cond_br %cond, %mux2 : i32
  %returnVal = d_return %condFalse2 : i32
  end %returnVal : i32
}
