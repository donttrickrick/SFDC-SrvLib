/**
 * Copyright 2017 donttrickrick@github.com
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, 
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, 
 *    this list of conditions and the following disclaimer in the documentation 
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors 
 *    may be used to endorse or promote products derived from this software without 
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
public without sharing class SrvLib_sObjectLikeList {
    @AuraEnabled
    public final List<sObject> l { get; private set; }
    
    public SrvLib_sObjectLikeList(List<sObject> sObjLst) {
        l = sObjLst == null ? new List<sObject>() : sObjLst;
    }
    public Integer count() {
        return l.size();
    }
    public sObject first() {
        return count() > 0 ? l[0] : null;
    }
    public sObject first(String field, Object predictedValue) {
        sObject firstObj = null;
        for(sObject sObj : l) {
            if(SrvLib_Primitives.valueOf(getDrillDownFieldFromExisting(sObj, field, true)).equals(predictedValue)) {
                firstObj = sObj;
                break;
            }
        }
        return firstObj;
    }
    public sObject last() {
        return count() > 0 ? l[count() - 1] : null;
    }
    public sObject last(String field, Object predictedValue) {
        sObject lastObj = null;
        for(Integer i = l.size() - 1; i > -1; i--) {
            sObject sObj = l[i];
            if(SrvLib_Primitives.valueOf(getDrillDownFieldFromExisting(sObj, field, true)).equals(predictedValue)) {
                lastObj = sObj;
                break;
            }
        }
        return lastObj;
    }
    public Map<String, sObject> toMap(String identityField) {
        Map<String, sObject> sObjectMap = new Map<String, sObject>();
        for(sObject sObj : l) {
            String key = String.valueOf(getDrillDownFieldFromExisting(sObj, identityField, true));
            sObjectMap.put(key, sObj);
        }
        return sObjectMap;
    }
    public List<Map<String, Object>> toObjectMap() {
        List<Map<String, Object>> lst = new List<Map<String, Object>>();
        for(sObject sObj : l) {
            Map<String, Object> sObjectMap = new Map<String, Object>(sObj.getPopulatedFieldsAsMap());
            if(!sObjectMap.containsKey('sobjectType')) {
                sObjectMap.put('sobjectType', sObj.getSObjectType());
            }
            lst.add(sObjectMap);
        }
        return lst;
    }
    public List<Map<String, Object>> toMockupMap(String fields, String mockupFieldName) {
        // List<Map<String, Map<String, Object>>> mLst = new List<Map<String, Map<String, Object>>>();
        List<Map<String, Object>> mLst = new List<Map<String, Object>>();
        mockupFieldName = String.isEmpty(mockupFieldName) ? 'field' : mockupFieldName;
        String[] fieldArray = fields.split('\\s*[,]\\s*');
        system.debug('fieldArray:'+fieldArray);
        
        for(sObject sObj : this.l) {
            // Map<String, Map<String, Object>> sMap = new Map<String, Map<String, Object>>();
            Map<String, Object> sMap = sObj.getPopulatedFieldsAsMap().clone();
            Integer i = 0;
            for(String fieldStr : fieldArray) {
                Object value = getDrillDownFieldFromExisting(sObj, fieldStr, true);
                
                sMap.put(mockupFieldName + i++, new Map<String, Object> {
                    'APIName' => fieldStr,
                    'Type' => String.valueOf(SrvLib_Primitives.valueOf(getDrillDownFieldFromExisting(sObj, fieldStr, true)).type),
                    'Value' => getDrillDownFieldFromExisting(sObj, fieldStr, true)
                });
            }
            mLst.add(sMap);
        }
        return mLst;
    }
    public SrvLib_sObjectLikeList whereNot(String field, Object predictedValue) {
        List<sObject> whereLst = new List<sObject>();
        for(sObject sObj : l) {
            if(!SrvLib_Primitives.valueOf(getDrillDownFieldFromExisting(sObj, field, true)).equals(predictedValue)) {
                whereLst.add(sObj);
            }
        }
        return new SrvLib_sObjectLikeList(whereLst);
    }
    public SrvLib_sObjectLikeList whereNotIn(String field, List<Object> predictedValueLst) {
        List<sObject> whereLst = new List<sObject>();
        for(sObject sObj : l) {
            Boolean isIn = false;
            for(Object predictedValue : predictedValueLst) {
                if(SrvLib_Primitives.valueOf(getDrillDownFieldFromExisting(sObj, field, true)).equals(predictedValue)) {
                    isIn = true;
                    break;
                }
            }
            if(!isIn) {
                whereLst.add(sObj);
            }
        }
        return new SrvLib_sObjectLikeList(whereLst);
    }
    public SrvLib_sObjectLikeList whereEql(String field, Object predictedValue) {
        List<sObject> whereLst = new List<sObject>();
        for(sObject sObj : l) {
            if(SrvLib_Primitives.valueOf(getDrillDownFieldFromExisting(sObj, field, true)).equals(predictedValue)) {
                whereLst.add(sObj);
            }
        }
        return new SrvLib_sObjectLikeList(whereLst);
    }
    public SrvLib_sObjectLikeList whereIn(String field, List<Object> predictedValueLst) {
        List<sObject> whereLst = new List<sObject>();
        for(sObject sObj : l) {
            Boolean isIn = false;
            for(Object predictedValue : predictedValueLst) {
                if(SrvLib_Primitives.valueOf(getDrillDownFieldFromExisting(sObj, field, true)).equals(predictedValue)) {
                    isIn = true;
                    break;
                }
            }
            if(isIn) {
                whereLst.add(sObj);
            }
        }
        return new SrvLib_sObjectLikeList(whereLst);
    }
    public Map<String, SrvLib_sObjectLikeList> groupBy(String field) {
        Map<String, List<sObject>> sObjectMap = new Map<String, List<sObject>>();
        for(sObject sObj : l) {
            List<sObject> sObjLst = null;
            String key = String.valueOf(getDrillDownFieldFromExisting(sObj, field, true));
            if(sObjectMap.containsKey(key)) {
                sObjLst = sObjectMap.get(key);
            } else {
                sObjLst = new List<sObject>();
                sObjectMap.put(key, sObjLst);
            }
            sObjLst.add(sObj);
        }
        Map<String, SrvLib_sObjectLikeList> sObjectLikeMap = new Map<String, SrvLib_sObjectLikeList>();
        for(String key : sObjectMap.keySet()) {
            sObjectLikeMap.put(key, new SrvLib_sObjectLikeList(sObjectMap.get(key)));
        }
        return sObjectLikeMap;
    }
    public SrvLib_sObjectLikeList groupByThenGet(String groupByField, String key) {
        SrvLib_sObjectLikeList lst = new SrvLib_sObjectLikeList(new List<sObject>());
        Map<String, SrvLib_sObjectLikeList> sObjMap = groupBy(groupByField);
        if(sObjMap.containsKey(key)) {
            lst = sObjMap.get(key);
        }
        return lst;
    }
    public Map<String, List<sObject>> groupByReturnSObject(String field) {
        Map<String, List<sObject>> sObjectMap = new Map<String, List<sObject>>();
        for(sObject sObj : l) {
            List<sObject> sObjLst = null;
            String key = String.valueOf(getDrillDownFieldFromExisting(sObj, field, true));
            if(sObjectMap.containsKey(key)) {
                sObjLst = sObjectMap.get(key);
            } else {
                sObjLst = new List<sObject>();
                sObjectMap.put(key, sObjLst);
            }
            sObjLst.add(sObj);
        }
        return sObjectMap;
    }
    public SrvLib_sObjectLikeList orderBy(String field) {
        List<SrvLib_Primitives.Value> valueLst = new List<SrvLib_Primitives.Value>();
        Map<SrvLib_Primitives.Value, List<sObject>> valueMap = new Map<SrvLib_Primitives.Value, List<sObject>>();
        for(sObject sObj : l) {
           SrvLib_Primitives.Value v = SrvLib_Primitives.valueOf(getDrillDownFieldFromExisting(sObj, field, true));
           List<sObject> subSObjLst = null;
           if(valueMap.containsKey(v)) {
               subSObjLst = valueMap.get(v);
           } else {
               subSObjLst = new List<sObject>();
               valueLst.add(v);
               valueMap.put(v, subSObjLst);
           }
           subSObjLst.add(sObj);
       }
       valueLst.sort();
       List<sObject> lst = new List<sObject>();
       for(SrvLib_Primitives.Value v : valueLst) {
           lst.addAll(valueMap.get(v));
       }
       return new SrvLib_sObjectLikeList(lst);
    }
    public SrvLib_sObjectLikeList orderByDESC(String field) {
        return orderBy(field).reverse();
    }
    public List<Object> selectAny(String field) {
        List<Object> objLst = new List<Object>();
        for(sObject sObj : l) {
            objLst.add(getDrillDownFieldFromExisting(sObj, field, true));
        }
        return objLst;
    }
    public List<String> selectString(String field) {
        List<String> objLst = new List<String>();
        for(sObject sObj : l) {
            objLst.add((String)getDrillDownFieldFromExisting(sObj, field, true));
        }
        return objLst;
    }
    public List<Id> selectId(String field) {
        List<Id> idLst = new List<Id>();
        for(sObject sObj : l) {
            idLst.add((Id)getDrillDownFieldFromExisting(sObj, field, true));
        }
        return idLst;
    }
    public SrvLib_sObjectLikeList selectSObject(String field) {
        List<sObject> sObjLst = new List<sObject>();
        for(sObject sObj : l) {
            sObjLst.add((sObject)getDrillDownFieldFromExisting(sObj, field, false));
        }
        return new SrvLib_sObjectLikeList(sObjLst);
    }
    public SrvLib_sObjectLikeList selectSObjects(String field) {
        List<sObject> sObjLst = new List<sObject>();
        for(sObject sObj : l) {
            sObjLst.addAll(sObj.getSObjects(field));
        }
        return new SrvLib_sObjectLikeList(sObjLst);
    }
    public SrvLib_sObjectLikeList concat(SrvLib_sObjectLikeList another) {
        List<sObject> lst = new List<sObject>();
        for(sObject sObj : this.l) {
            lst.add(sObj);
        }
        for(sObject sObj : another.l) {
            lst.add(sObj);
        }
        return new SrvLib_sObjectLikeList(lst);
    }
    public SrvLib_sObjectLikeList distinct(String field) {
        List<sObject> cloned = l.clone(); // shallow clone
        for(Integer i = 0; i < cloned.size(); i++) {
            for(Integer j = i + 1; j < cloned.size(); j++) {
                if(SrvLib_Primitives.valueOf(getDrillDownFieldFromExisting(cloned[i], field, true)).equals(getDrillDownFieldFromExisting(cloned[j], field, true))) {
                    cloned.remove(j);
                    j--;
                }
            }
        }
        return new SrvLib_sObjectLikeList(cloned);
    }
    public Boolean one(String field, List<Object> predictedValueLst) {
        Boolean ret = false;
        for(sObject sObj : l) {
            for(Object predictedValue : predictedValueLst) {
                ret |= getDrillDownFieldFromExisting(sObj, field, true).equals(predictedValue);
            }
            if(ret) {
                break;
            }
        }
        return ret;
    }
    public Boolean all(String field, List<Object> predictedValueLst) {
        Boolean ret = null;
        for(sObject sObj : l) {
            for(Object predictedValue : predictedValueLst) {
                ret = ret == null ? getDrillDownFieldFromExisting(sObj, field, true).equals(predictedValue) : ret & getDrillDownFieldFromExisting(sObj, field, true).equals(predictedValue);
            }
            if(!ret) {
                break;
            }
        }
        return ret;
    }
    public Boolean one(String field, Object predictedValue) {
        Boolean ret = false;
        for(sObject sObj : l) {
            if(getDrillDownFieldFromExisting(sObj, field, true).equals(predictedValue)) {
                ret = true;
                break;
            }
        }
        return ret;
    }
    public Boolean all(String field, Object predictedValue) {
        Boolean ret = null;
        for(sObject sObj : l) {
            ret = ret == null ? getDrillDownFieldFromExisting(sObj, field, true).equals(predictedValue) : ret & getDrillDownFieldFromExisting(sObj, field, true).equals(predictedValue);
            if(!ret) {
                break;
            }
        }
        return ret;
    }
    public Boolean isEmpty() {
        return count() == 0;
    }
    public Boolean isSingle() {
        return count() == 1;
    }
    public Boolean areAllDistinct(String fieldName) {
        Boolean ret = true;
        for(SrvLib_sObjectLikeList sObjLst : this.groupBy(fieldName).values()) {
            if(sObjLst.count() > 1) {
                ret = false;
                break;
            }
        }
        return ret;
    }
    public SrvLib_sObjectLikeList reverse() {
        List<sObject> reversed = new List<sObject>();
        for(Integer i = l.size() - 1; i >= 0; i--) {
            reversed.add(l[i]);
        }
        return new SrvLib_sObjectLikeList(reversed);
    }
    public SrvLib_sObjectLikeList take(Integer size) {
        List<sObject> lst = new List<sObject>();
        for(Integer i = 0; i < size && i < l.size(); i++) {
            lst.add(l[i]);
        }
        return new SrvLib_sObjectLikeList(lst);
    }
    public Object sum(String field) {
        SrvLib_Primitives.Value ret = new SrvLib_Primitives.ObjectValue(null);
        for(sObject sObj : l) {
            system.debug('ret.value:'+ret.value);
            ret = ret.value == null ? SrvLib_Primitives.valueOf(getDrillDownFieldFromExisting(sObj, field, true)) : ret.add(getDrillDownFieldFromExisting(sObj, field, true));
        }
        return ret.value;
    }
    public Object average(String field) {
        SrvLib_Primitives.Value ret = new SrvLib_Primitives.ObjectValue(null);
        for(sObject sObj : l) {
            ret = ret.value == null ? SrvLib_Primitives.valueOf(getDrillDownFieldFromExisting(sObj, field, true)) : ret.add(getDrillDownFieldFromExisting(sObj, field, true));
        }
        System.assert(count() != 0, 'average: List size is 0. Cannot calculate average.');
        ret = ret.divide(new SrvLib_Primitives.IntegerValue(count()));
        return ret.value;
    }
    public Object max(String field) {
        SrvLib_Primitives.Value ret = new SrvLib_Primitives.ObjectValue(null);
        for(sObject sObj : l) {
            ret = ret.value != null && ret.lessThan(getDrillDownFieldFromExisting(sObj, field, true)) ? ret : SrvLib_Primitives.valueOf(getDrillDownFieldFromExisting(sObj, field, true));
        }
        return ret.value;
    }
    public Object min(String field) {
        SrvLib_Primitives.Value ret = new SrvLib_Primitives.ObjectValue(null);
        for(sObject sObj : l) {
            ret = ret.value != null && ret.greaterThan(getDrillDownFieldFromExisting(sObj, field, true)) ? ret : SrvLib_Primitives.valueOf(getDrillDownFieldFromExisting(sObj, field, true));
        }
        return ret.value;
    }
    private Object getDrillDownFieldFromExisting(sObject sObj, String field, Boolean notQueryParentRelationship) {
        String[] drillDownArray = field.trim().split('[.]');
        Object ret = sObj;

        if(drillDownArray.size() == 1) {
            ret = sObj.get(drillDownArray[0]);
        } else {
            for(Integer i = 0; i < drillDownArray.size(); i++) {
                if(notQueryParentRelationship && i == drillDownArray.size() - 1) {
                    //system.debug('ret:'+ret);
                    //system.debug('drillDownArray:'+drillDownArray);
                    //system.debug('drillDownArray[i]:'+drillDownArray[i]);
                    ret = ((sObject)ret).get(drillDownArray[i]);
                } else {
                    ret = ((sObject)ret).getSObject(drillDownArray[i]);
                    if(ret == null) {
                        break;
                    }
                }
            }
        }
        
        return ret;
    }
    
    
    /* Todo
    public Object aggregate(String field) {
        SrvLib_Primitives.Value ret = new SrvLib_Primitives.ObjectValue(null);
        for(sObject sObj : l) {
            ret = ret.value == null || sObj.getValue(field).lessThan(ret) ? sObj.getValue(field) : ret;
        }
        return ret;
    }
    public SrvLib_sObjectLikeList union(SrvLib_sObjectLikeList another) {
        List<sObject> newLst = new List<sObject>();
        newLst.addAll(this.original);
        newLst.addAll(another.original);
        return new SrvLib_sObjectLikeList(newLst);
    }
    public SrvLib_sObjectLikeList except(SrvLib_sObjectLikeList another) {
        List<sObject> newLst = new List<sObject>();
        newLst.addAll(this.original);
        newLst.addAll(another.original);
        return new SrvLib_sObjectLikeList(newLst);
    }
    public SrvLib_sObjectLikeList intersect(SrvLib_sObjectLikeList another) {
        List<sObject> newLst = new List<sObject>();
        newLst.addAll(this.original);
        newLst.addAll(another.original);
        return new SrvLib_sObjectLikeList(newLst);
    }
    
    */
    // public SrvLib_sObjectLikeList doAction(ILikeActionInvokable action, Map<String, Object> params) {
    //    for(sObject sObj : l) {
    //         action.invoke(sObj, params);
    //     }
    //     return this;
    // }
    
    // public SrvLib_sObjectLikeList doBulkAction(ILikeListActionInvokable action, Map<String, Object> params) {
    //     action.invoke(this, params);
    //     return this;
    // }
}
