package com.zengshuai.crm.vo;

import java.util.List;

/**
*function:  -
*project:   crm
*author:    cengs
*version:   1.0 2019/7/1_12:12 
*/
public class Pagination<T> {
    private int totalRecord;
    private List<T> dataList;

    public Pagination(int totalRecord, List<T> dataList) {
        this.totalRecord = totalRecord;
        this.dataList = dataList;
    }

    public Pagination() {
    }

    public int getTotalRecord() {
        return totalRecord;
    }

    public void setTotalRecord(int totalRecord) {
        this.totalRecord = totalRecord;
    }

    public List<T> getDataList() {
        return dataList;
    }

    public void setDataList(List<T> dataList) {
        this.dataList = dataList;
    }
}
