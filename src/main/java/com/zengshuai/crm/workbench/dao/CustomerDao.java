package com.zengshuai.crm.workbench.dao;

import com.zengshuai.crm.workbench.domain.Customer;

import java.util.List;

public interface CustomerDao {

    int createCustomer(Customer customer);

    Customer checkByName(String company);

    List<String> getCustomerName(String cname);

    Customer findCustomerByName(String customerName);

    int saveCustomer(Customer customer);
}
