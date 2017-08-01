public class SrvLib_sObjectDataListService {
    private QueryResult result = new QueryResult();

    private String pieceWhereQueryString(List<FilterFactor> factorLst, String filterLogic) {
        String whereString = '';
        if(filterLogic != '-1') {
            whereString = String.isEmpty(filterLogic) ? '' : ' WHERE ' + Pattern.compile('\\d+').matcher(filterLogic).replaceAll('##$0##');
            String connectWord = ' WHERE ';

            if(factorLst != null) {
                Integer i = 1;
                for(FilterFactor factor : factorLst) {
                    if(factor.isFilterOnChildSObject == true) {
                        List<Id> idLst = getParentIdLstFromFilterOnChild(factor.childSObjectName, factor.childFilterConditionString, factor.parentIdFieldNameOnChild);
                        if(String.isEmpty(filterLogic)) {
                            whereString += connectWord 
                                        + ' (Id IN ' + SrvLib_sObjectDataListService.toString4ListMembers(idLst) + ')';
                            connectWord = ' AND ';
                        } else {
                            whereString = whereString.replace('##' + String.valueOf(i) + '##', ' (Id IN ' + SrvLib_sObjectDataListService.toString4ListMembers(idLst) + ')'); 
                        }
                    } else {
                        if(String.isEmpty(filterLogic)) {
                            whereString += connectWord + '(' + factor.filterConditionString + ')';
                            connectWord = ' AND ';
                        } else {
                            whereString = whereString.replace('##' + String.valueOf(i) + '##', '(' + factor.filterConditionString + ')'); 
                        }
                    }
                    i++;
                }
            }	
        }
        return whereString;
    }

    private List<Id> getParentIdLstFromFilterOnChild(String sObjectTypeName, String childFilterConditionString, String parentIdFieldNameOnChild) {
        String childQueryString = 'SELECT Id, ' 
                                + parentIdFieldNameOnChild 
            					+ ' FROM ' + sObjectTypeName
                                + ' WHERE (' + childFilterConditionString + ')'
            					+ ' LIMIT 50000';
        System.debug('*** childQueryString:' + childQueryString);
        this.result.query += 'childQueryString:' + childQueryString + '\n';
        return SrvLib_sObjectDataListService.selectId(Database.query(childQueryString), parentIdFieldNameOnChild);
    }

    private String pieceOrderbyQueryString(List<SortFactor> factorLst) {
        String orderByString = '';
        if(factorLst != null) {
            String connectWord = ' ORDER BY ';
            for(SortFactor factor : factorLst) {
                orderByString += connectWord + factor.sortFieldName;
                orderByString += factor.isDESC == true ? ' DESC ': '';
                connectWord = ' , ';
            }
        }
        return orderByString;
    }

    // filterLogic: null or empty mean "All AND" logic. -1 means no where filter
    public QueryResult loadWellCookedDataList(QueryFactor qFactor, List<SortFactor> sFactorLst, List<FilterFactor> fFactorLst, String filterLogic, PaginationFactor pFactor) {
        doQueryFilterAndSort(qFactor, sFactorLst, fFactorLst, filterLogic);
        doPagination(pFactor);
        return this.result;
    }

    private List<sObject> doQueryFilterAndSort(QueryFactor qFactor, List<SortFactor> sFactorLst, List<FilterFactor> fFactorLst, String filterLogic) {
        String queryString = 'SELECT ' + qFactor.queryFields 
                            + ' FROM ' + qFactor.sObjectTypeName 
                            + pieceWhereQueryString(fFactorLst, filterLogic) 
                            + pieceOrderbyQueryString(sFactorLst)
            				+ ' LIMIT 50000';
        System.debug('*** queryString:' + queryString);
        this.result.query += 'queryString:' + queryString + '\n';
        this.result.sObjectLst = Database.query(queryString);
        return this.result.sObjectLst;
    }

    private List<sObject> doPagination(PaginationFactor factor) {
		List<sObject> ret = this.result.sObjectLst;
        if(factor != null) {
        	Integer startIndex = factor.sizeOnePage * factor.currentPageIndex;
            Integer endIndex = startIndex + factor.sizeOnePage - 1;
            this.result.sObjectLst = SrvLib_sObjectDataListService.take(this.result.sObjectLst, startIndex, endIndex);
            this.result.noPreviousPage = factor.currentPageIndex == 0;
            this.result.noNextPage = endIndex >= this.result.sObjectLst.size() - 1;
        }
        return ret;
    }


    // Static Utility Function. To do: put in utility class
    // Use this when manually piecing up SOQL string. For IN ...
    public static String toString4ListMembers(Object[] objLst) {
        String listString = '(';
        
        for(Object obj : objLst) {
            listString += '\'' + toStringReturnEmptyIfNull(obj) + '\',';
        }
        if(objLst.size() > 0) {
            listString = listString.removeEnd(',');
        } else {
            listString += 'null';
        }
        listString += ')';

        return listString;
    }

    // View Model need this to avoid null result.
    public static String toStringReturnEmptyIfNull(Object obj) {
        String str = '';
        if(obj == null) {
            return str;
        }
        str = String.valueOf(obj);
        return str;
    } 

    public static List<Id> selectId(List<sObject> l, String field) {
        List<Id> idLst = new List<Id>();
        for(sObject sObj : l) {
            idLst.add((Id)getDrillDownFieldFromExisting(sObj, field, true));
        }
        return idLst;
    }

    public static List<sObject> take(List<sObject> l, Integer startIndex, Integer endIndex) {
        List<sObject> lst = new List<sObject>();
        for(Integer i = startIndex; i <= endIndex && i < l.size(); i++) {
            lst.add(l[i]);
        }
        return lst;
    }
    private static Object getDrillDownFieldFromExisting(sObject sObj, String field, Boolean notQueryParentRelationship) {
        String[] drillDownArray = field.trim().split('[.]');
        Object ret = sObj;

        if(drillDownArray.size() == 1) {
            ret = sObj.get(drillDownArray[0]);
        } else {
            for(Integer i = 0; i < drillDownArray.size(); i++) {
                if(notQueryParentRelationship && i == drillDownArray.size() - 1) {
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

    // Static Utility Function End

    
    public class QueryResult {
        @AuraEnabled
        public List<sObject> sObjectLst;
        @AuraEnabled
        public Boolean noNextPage;
        @AuraEnabled
        public Boolean noPreviousPage;
        public String query;
        public QueryResult() {
            query = '';
        }
    }

    public class QueryFactor {
        public String sObjectTypeName;
        public String queryFields;

        public QueryFactor(String sObjectTypeName, String queryFields) {
        	this.sObjectTypeName = sObjectTypeName;
        	this.queryFields = queryFields;
        }
    }

    public class FilterFactor {
        public Boolean isFilterOnChildSObject;
        public String filterConditionString;
        public String childSObjectName;
        public String childFilterConditionString;
        public String parentIdFieldNameOnChild;

        public FilterFactor(Boolean isFilterOnChildSObject, String filterConditionString, String childSObjectName, String childFilterConditionString, String parentIdFieldNameOnChild) {
        	this.isFilterOnChildSObject = isFilterOnChildSObject;
        	this.filterConditionString = filterConditionString;
        	this.childSObjectName = childSObjectName;
        	this.childFilterConditionString = childFilterConditionString;
        	this.parentIdFieldNameOnChild = parentIdFieldNameOnChild;
        }
    }

    public class SortFactor {
        public Boolean isDESC;
        public String sortFieldName;

        public SortFactor(Boolean isDESC, String sortFieldName) {
        	this.isDESC = isDESC;
        	this.sortFieldName = sortFieldName;
        }
    }

    public class PaginationFactor {
        public Integer currentPageIndex;
        public Integer sizeOnePage;

        public PaginationFactor(Integer currentPageIndex, Integer sizeOnePage) {
        	this.currentPageIndex = currentPageIndex;
        	this.sizeOnePage = sizeOnePage;
        }
    }

}
