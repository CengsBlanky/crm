package com.zengshuai.crm.workbench.service.impl;

import com.zengshuai.crm.exception.ConvertException;
import com.zengshuai.crm.settings.domain.User;
import com.zengshuai.crm.utils.DateTimeUtil;
import com.zengshuai.crm.utils.SqlSessionUtil;
import com.zengshuai.crm.utils.UUIDUtil;
import com.zengshuai.crm.vo.Pagination;
import com.zengshuai.crm.workbench.dao.*;
import com.zengshuai.crm.workbench.domain.*;
import com.zengshuai.crm.workbench.service.ClueService;

import java.util.*;

/**
*function:  -
*project:   crm
*author:    cengs
*version:   1.0 2019/7/4_14:03 
*/
public class ClueServiceImpl  implements ClueService {

    private ClueDao cd = SqlSessionUtil.getSqlSession().getMapper(ClueDao.class);

    private ClueActivityRelationDao relationDao = SqlSessionUtil.getSqlSession().getMapper(ClueActivityRelationDao.class);

    private ClueRemarkDao clueRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ClueRemarkDao.class);

    private ContactsDao contactsDao = SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);

    private ContactsRemarkDao contactsRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ContactsRemarkDao.class);

    private ContactsActivityRelationDao contactsActivityRelationDao = SqlSessionUtil.getSqlSession().getMapper(ContactsActivityRelationDao.class);

    private CustomerDao customerDao =   SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);

    private CustomerRemarkDao customerRemarkDao = SqlSessionUtil.getSqlSession().getMapper(CustomerRemarkDao.class);

    private TranDao tranDao = SqlSessionUtil.getSqlSession().getMapper(TranDao.class);

    private TranHistoryDao tranHistoryDao = SqlSessionUtil.getSqlSession().getMapper(TranHistoryDao.class);

    @Override
    public List<User> findUsers() {
        return cd.findUsers();
    }

    @Override
    public Pagination<Clue> disClueList(Map<String, Object> map) {
        int totalRecord = cd.getTotalRecord(map);
        List<Clue> cList = cd.getClueList(map);
        Pagination<Clue> pagination = new Pagination<>();
        pagination.setTotalRecord(totalRecord);
        pagination.setDataList(cList);
        return pagination;
    }

    @Override
    public boolean saveClue(Clue clue) {
        int flag = cd.saveClue(clue);
        return flag==1;
    }

    @Override
    public Clue getClueById(String id) {
        return cd.getClueById(id);
    }

    @Override
    public List<Activity> findActivities(String clueId) {
        return cd.findActivities(clueId);
    }

    @Override
    public List<Activity> searchActivityByName(String aname, String clueId) {
        Map<String,String> map = new HashMap<>();
        map.put("aname",aname);
        map.put("clueId",clueId);
        return cd.searchActivityByName(map);
    }

    @Override
    public boolean bundActivity(String clueId, String[] activityIds) {
        int flag = 0;
        for(String aid:activityIds){
            ClueActivityRelation relation = new ClueActivityRelation();
            String bundId = UUIDUtil.getUUID();
            relation.setId(bundId);
            relation.setClueId(clueId);
            relation.setActivityId(aid);
            flag = relationDao.insertIntoBundTable(relation);
        }
        return flag==1;
    }

    @Override
    public List<Activity> searchActivityOnlyByName(String aname) {
        return cd.searchActivityOnlyByName(aname);
    }

    @Override
    public boolean deleteRelation(String clueId, String aId) {
        ClueActivityRelation relation = new ClueActivityRelation();
        relation.setActivityId(aId);
        relation.setClueId(clueId);
        int flag = relationDao.deleteRelation(relation);
        return flag==1;
    }

    @Override
    public void convert(Transaction transaction, String clueId) throws ConvertException{
        //获取线索对象
        Clue clue = cd.findClueById(clueId);
        //为客户表铺值，首先判断客户是否已经存在
        Customer customer = null;
        String company = clue.getCompany();
        customer = customerDao.checkByName(company);
        //如果客户不存在，新建一个客户；存在则不必新建
        if(customer==null) {
            customer = new Customer();
            customer.setId(UUIDUtil.getUUID());
            customer.setOwner(clue.getOwner());
            //客户名称是公司名
            customer.setName(company);
            customer.setWebsite(clue.getWebsite());
            customer.setPhone(clue.getPhone());
            customer.setCreateBy(clue.getCreateBy());
            customer.setCreateTime(DateTimeUtil.getSysTime());
            customer.setContactSummary(clue.getContactSummary());
            customer.setNextContactTime(clue.getNextContactTime());
            customer.setDescription(clue.getDescription());
            customer.setAddress(clue.getAddress());
            int flagCus = customerDao.createCustomer(customer);
            if (flagCus != 1) {
               throw new ConvertException("新建客户失败！");
            }
        }
        //新建一个联系人
        Contacts contacts = new Contacts();
        contacts.setId(UUIDUtil.getUUID());
        contacts.setOwner(clue.getOwner());
        contacts.setSource(clue.getSource());
        contacts.setCustomerId(customer.getId());
        contacts.setFullname(clue.getFullname());
        contacts.setAppellation(clue.getAppellation());
        contacts.setEmail(clue.getEmail());
        contacts.setMphone(clue.getMphone());
        contacts.setJob(clue.getJob());
        contacts.setCreateBy(clue.getCreateBy());
        contacts.setCreateTime(DateTimeUtil.getSysTime());
        contacts.setDescription(clue.getDescription());
        contacts.setContactSummary(clue.getContactSummary());
        contacts.setNextContactTime(clue.getNextContactTime());
        int flagCon = contactsDao.createContact(contacts);
        if(flagCon!=1){
           throw new ConvertException("新建联系人失败");
        }

        //将线索备注转移到客户和联系人备注中
        List<ClueRemark> clueRemarkList= clueRemarkDao.searchRemarkByClueId(clueId);
        if (clueRemarkList.size()!=0) {
            for (ClueRemark clueRemark:clueRemarkList) {
                ContactsRemark contactsRemark = new ContactsRemark();
                contactsRemark.setId(UUIDUtil.getUUID());
                contactsRemark.setNoteContent(clueRemark.getNoteContent());
                contactsRemark.setCreateBy(clueRemark.getCreateBy());
                contactsRemark.setCreateTime(clueRemark.getCreateTime());
                contactsRemark.setEditFlag(clueRemark.getEditFlag());
                contactsRemark.setContactsId(contacts.getId());
                contactsRemark.setEditBy(clueRemark.getEditBy());
                contactsRemark.setEditTime(clueRemark.getEditTime());
                int flagConRemark = contactsRemarkDao.createRemark(contactsRemark);
                if (flagConRemark != 1) {
                    throw new ConvertException("线索备注转移至联系人备注失败");
                }
                CustomerRemark customerRemark = new CustomerRemark();
                customerRemark.setId(UUIDUtil.getUUID());
                customerRemark.setNoteContent(clueRemark.getNoteContent());
                customerRemark.setCreateBy(clueRemark.getCreateBy());
                customerRemark.setCreateTime(clueRemark.getCreateTime());
                customerRemark.setEditBy(clueRemark.getEditBy());
                customerRemark.setEditTime(clueRemark.getEditTime());
                customerRemark.setEditFlag(clueRemark.getEditFlag());
                customerRemark.setCustomerId(customer.getId());
                int flagCusRemark = customerRemarkDao.createRemark(customerRemark);
                if (flagCusRemark != 1) {
                    throw new ConvertException("线索备注转移至客户备注失败");
                }
            }
        }


        //将线索-活动关系转换为联系人-活动关系
        //先根据线索id查到活动id，再将活动id和联系人id插入到联系人-活动关系表中
        String[] aids = relationDao.searchActivityIdByClueId(clueId);
        if (aids.length!=0) {
            for(String aid:aids){
                ContactsActivityRelation contactsActivityRelation = new ContactsActivityRelation();
                contactsActivityRelation.setId(UUIDUtil.getUUID());
                contactsActivityRelation.setContactsId(contacts.getId());
                contactsActivityRelation.setActivityId(aid);
                int flagRelation = contactsActivityRelationDao.createRelation(contactsActivityRelation);
                if(flagRelation!=1){
                    throw new ConvertException("新建联系人-活动关系失败");
                }
            }
        }


        //判断交易是否为空,为空则不创建交易，否则创建交易
        if(transaction !=null){
            //创建一条交易
            transaction.setOwner(clue.getOwner());
            transaction.setCustomerId(customer.getId());
            transaction.setSource(clue.getSource());
            transaction.setContactsId(contacts.getId());
            transaction.setContactSummary(contacts.getContactSummary());
            transaction.setNextContactTime(contacts.getNextContactTime());
            int flagTran = tranDao.createTran(transaction);
            if(flagTran!=1){
                throw new ConvertException("交易创建失败");
            }
            //创建一条交易历史
            TranHistory history = new TranHistory();
            history.setId(UUIDUtil.getUUID());
            history.setCreateBy(transaction.getCreateBy());
            history.setCreateTime(transaction.getCreateTime());
            history.setTranId(transaction.getId());
            history.setStage(transaction.getStage());
            history.setMoney(transaction.getMoney());
            history.setExpectedDate(transaction.getExpectedDate());
            int flagHistory = tranHistoryDao.createHistory(history);
            if(flagHistory!=1){
                throw new ConvertException("交易历史创建失败");
            }
        }

        //删除线索备注,删除多条，需要先查找再删除以判断删除是否成功
        int toBeDeletedRemarkCount = clueRemarkDao.toBeDeletedCount(clueId);
        int flagDeletelueRemark = clueRemarkDao.deleteRemarkByClueId(clueId);
        if(flagDeletelueRemark!=toBeDeletedRemarkCount){
            throw new ConvertException("删除线索备注失败");
        }
        //删除线索活动关系
        int toBeDeletedRelationCount = relationDao.toBeDeletedRelationCount(clueId);
        int flagDeleteClueActivityRelation = relationDao.deleteRelationByClueId(clueId);
        if(flagDeleteClueActivityRelation!=toBeDeletedRelationCount){
            throw new ConvertException("删除线索活动关系失败");
        }
        //删除线索
        int flagDeleteClue = cd.deleteClueById(clueId);
        if(flagDeleteClue!=1){
            throw new ConvertException("删除线索失败");
        }
    }
}
