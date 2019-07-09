package com.zengshuai.crm.workbench.dao;

import com.zengshuai.crm.workbench.domain.Contacts;

import java.util.List;

public interface ContactsDao {

    int createContact(Contacts contacts);

    List<Contacts> searchContactByName(String fullname);
}
