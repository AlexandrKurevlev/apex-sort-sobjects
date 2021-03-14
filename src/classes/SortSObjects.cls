/**
 * Class for sorting SObjects by any field(s) with a primitive data type<p>
 *
 * Example usage:
 * <pre>
 *     List&lt;Contact&gt; sortedContacts = new SortSObjects()
 *          .ascending(Contact.FirstName)
 *          .ascending(Contact.LastName)
 *          .sort(contacts);
 * </pre>
 */
public with sharing class SortSObjects {

    private List<SortField> sortFields;

    public SortSObjects() {
        this.sortFields = new List<SortField>();
    }

    /**
     * Add field to sort in ascending order<p>
     * <code>null</code> values will be at the end
     *
     * @param sortField
     *
     * @return
     */
    public SortSObjects ascending(SObjectField sortField) {
        return ascending(sortField, true);
    }

    /**
     * Add field to sort in ascending order
     *
     * @param sortField
     * @param nullsLast <code>true</code> if <code>null</code> values should be at the end, <code>false</code> if they should be at the beginning
     *
     * @return
     */
    public SortSObjects ascending(SObjectField sortField, Boolean nullsLast) {
        addSortField(sortField, SortOrder.ASCENDING, nullsLast);
        return this;
    }

    /**
     * Add field to sort in descending order<p>
     * <code>null</code> values will be at the end
     *
     * @param sortField
     *
     * @return
     */
    public SortSObjects descending(SObjectField sortField) {
        return descending(sortField, true);
    }

    /**
     * Add field to sort in descending order
     *
     * @param sortField
     * @param nullsLast <code>true</code> if <code>null</code> values should be at the end, <code>false</code> if they should be at the beginning
     *
     * @return
     */
    public SortSObjects descending(SObjectField sortField, Boolean nullsLast) {
        addSortField(sortField, SortOrder.DESCENDING, nullsLast);
        return this;
    }

    /**
     * Perform sorting
     *
     * @param sObjectsToSort records to sort
     *
     * @return sorted list
     */
    public List<SObject> sort(List<SObject> sObjectsToSort) {
        List<SObjectWrapper> allRecords = new List<SObjectWrapper>();
        for (SObject sobj : sObjectsToSort) {
            allRecords.add(new SObjectWrapper(sobj, sortFields));
        }

        allRecords.sort();

        List<SObject> result = new List<SObject>();
        for (SObjectWrapper sObjectWrapper : allRecords) {
            result.add(sObjectWrapper.record);
        }

        return result;
    }

    private void addSortField(SObjectField sortField, SortOrder sortOrder, Boolean nullsLast) {
        sortFields.add(new SortField(sortField, sortOrder, nullsLast));
    }

    private class SObjectWrapper implements Comparable {

        private SObject record;
        private List<SortField> sortFields;

        SObjectWrapper(SObject record, List<SortField> sortFields) {
            this.record = record;
            this.sortFields = sortFields;
        }

        public Integer compareTo(Object anotherObject) {
            SObject anotherRecord = ((SObjectWrapper) anotherObject).record;
            if (record == null && anotherRecord == null) {
                return 0;
            }

            if (record == null) {
                return 1;
            }

            if (anotherRecord == null) {
                return -1;
            }

            Integer result = 0;
            for (SortField sortField : sortFields) {
                if (result != 0) {
                    break;
                }

                SObjectField field = sortField.field;
                Object fieldValue1 = record.get(field);
                Object fieldValue2 = anotherRecord.get(field);

                if (fieldValue1 == null && fieldValue2 == null) {
                    result = 0;
                    continue;
                }

                if (fieldValue1 == null) {
                    result = sortField.nullsLast ? 1 : -1;
                    continue;
                }

                if (fieldValue2 == null) {
                    result = sortField.nullsLast ? -1 : 1;
                    continue;
                }

                switch on field.getDescribe().getSoapType() {
                    when INTEGER {
                        result = compareIntegers((Integer) fieldValue1, (Integer) fieldValue2);
                    }
                    when DOUBLE {
                        result = compareDoubles((Double) fieldValue1, (Double) fieldValue2);
                    }
                    when STRING, ID {
                        result = compareStrings((String) fieldValue1, (String) fieldValue2);
                    }
                    when DATE {
                        result = compareDates((Date) fieldValue1, (Date) fieldValue2);
                    }
                    when DATETIME {
                        result = compareDatetimes((Datetime) fieldValue1, (Datetime) fieldValue2);
                    }
                    when TIME {
                        result = compareTimes((Time) fieldValue1, (Time) fieldValue2);
                    }
                    when BOOLEAN {
                        result = compareBooleans((Boolean) fieldValue1, (Boolean) fieldValue2);
                    }
                }

                result *= sortField.sortOrder == SortOrder.ASCENDING ? 1 : -1;
            }

            return result;
        }

        private Integer compareIntegers(Integer v1, Integer v2) {
            return v1 - v2;
        }

        private Integer compareDoubles(Double v1, Double v2) {
            if (v1 > v2) {
                return 1;
            } else if (v1 < v2) {
                return -1;
            } else {
                return 0;
            }
        }

        private Integer compareStrings(String v1, String v2) {
            return v1.compareTo(v2);
        }

        private Integer compareDates(Date v1, Date v2) {
            return v2.daysBetween(v1);
        }

        private Integer compareDatetimes(Datetime v1, Datetime v2) {
            return (v1.getTime() - v2.getTime()).intValue();
        }

        private Integer compareTimes(Time v1, Time v2) {
            Datetime d1 = Datetime.newInstance(Date.newInstance(2020, 2, 2), v1);
            Datetime d2 = Datetime.newInstance(Date.newInstance(2020, 2, 2), v2);
            return compareDatetimes(d1, d2);
        }

        private Integer compareBooleans(Boolean v1, Boolean v2) {
            Integer i1 = v1 ? 1 : 0;
            Integer i2 = v2 ? 1 : 0;
            return compareIntegers(i1, i2);
        }
    }

    private enum SortOrder {
        ASCENDING, DESCENDING
    }

    private class SortField {
        private SObjectField field;
        private SortOrder sortOrder;
        private Boolean nullsLast;

        SortField(SObjectField field, SortOrder sortOrder, Boolean nullsLast) {
            this.field = field;
            this.sortOrder = sortOrder;
            this.nullsLast = nullsLast;
        }
    }
}