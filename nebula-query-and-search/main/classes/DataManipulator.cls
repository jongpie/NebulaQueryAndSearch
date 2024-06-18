/*******************************************************************************************************
 * This file is part of the Nebula Query & Search project, released under the MIT License.             *
 * Copyright (c) 2018, Jonathan Gillespie. All rights reserved.                                        *
 * See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
 ******************************************************************************************************/

/**
 *
 * @group Repository
 *
 * @description Provides methods with default behavior for DML actions (insert, upsert, etc)
 *
 */
global inherited sharing abstract class DataManipulator {
  private static final System.AccessLevel DEFAULT_ACCESS_LEVEL = System.AccessLevel.USER_MODE;
  private static final Database.DMLOptions DEFAULT_DML_OPTIONS {
    get {
      if (DEFAULT_DML_OPTIONS == null) {
        DEFAULT_DML_OPTIONS = new Database.DMLOptions();
        DEFAULT_DML_OPTIONS.AllowFieldTruncation = false;
        DEFAULT_DML_OPTIONS.OptAllOrNone = true;
      }
      return DEFAULT_DML_OPTIONS;
    }
    set;
  }

  private final System.AccessLevel accessLevel;
  private final Database.DMLOptions dmlOptions;

  protected DataManipulator() {
    this(DEFAULT_ACCESS_LEVEL, DEFAULT_DML_OPTIONS);
  }

  protected DataManipulator(System.AccessLevel accessLevel, Database.DMLOptions dmlOptions) {
    this.accessLevel = accessLevel.clone();
    this.dmlOptions = dmlOptions.clone();
  }

  global virtual List<Database.SaveResult> insertData(SObject record) {
    return this.insertData(new List<SObject>{ record });
  }

  global virtual List<Database.SaveResult> insertData(List<SObject> records) {
    return Database.insert(records);
  }

  global virtual List<Database.SaveResult> updateData(SObject record) {
    return this.updateData(new List<SObject>{ record });
  }

  global virtual List<Database.SaveResult> updateData(List<SObject> records) {
    return Database.update(records);
  }

  global virtual List<Database.UpsertResult> upsertData(SObject record) {
    return this.upsertData(this.castRecords(record));
  }

  global virtual List<Database.UpsertResult> upsertData(List<SObject> records) {
    return Database.upsert(records);
  }

  global virtual List<Database.UpsertResult> upsertData(SObject record, Schema.SObjectField externalIdField) {
    return this.upsertData(this.castRecords(record), externalIdField);
  }

  global virtual List<Database.UpsertResult> upsertData(List<SObject> records, Schema.SObjectField externalIdField) {
    return Database.upsert(records, externalIdField);
  }

  global virtual List<Database.UndeleteResult> undeleteData(SObject record) {
    return this.undeleteData(new List<SObject>{ record });
  }

  global virtual List<Database.UndeleteResult> undeleteData(List<SObject> records) {
    return Database.undelete(records);
  }

  global virtual List<Database.DeleteResult> softDeleteData(SObject record) {
    return this.softDeleteData(new List<SObject>{ record });
  }

  global virtual List<Database.DeleteResult> softDeleteData(List<SObject> records) {
    return Database.delete(records);
  }

  global virtual List<Database.DeleteResult> hardDeleteData(SObject record) {
    return this.hardDeleteData(new List<SObject>{ record });
  }

  global virtual List<Database.DeleteResult> hardDeleteData(List<SObject> records) {
    List<Database.DeleteResult> results = this.softDeleteData(records);
    if (records.isEmpty() == false) {
      Database.emptyRecycleBin(records);
    }
    return results;
  }

  protected System.AccessLevel getAccessLevel() {
    return this.accessLevel;
  }

  // protected void setAccessLevel(System.AccessLevel accessLevel) {
  //   this.accessLevel = accessLevel;
  // }

  protected virtual Database.DMLOptions getDMLOptions() {
    return this.dmlOptions;
  }

  // protected void setDMLOptions(Database.DMLOptions dmlOptions) {
  //   this.dmlOptions = dmlOptions;
  // }

  private List<SObject> castRecords(SObject record) {
    // Salesforce will only allow upsert calls for SObjects if a declared-type list is passed in.
    // This is fine for the bulk method, where we can assume the caller is passing in an explicit list, but for a single record,
    // the only way to successfully perform the upsert is to dynamically spin up a list of the SObject's type

    String listType = 'List<' + record.getSObjectType() + '>';
    List<SObject> castRecords = (List<SObject>) Type.forName(listType).newInstance();
    castRecords.add(record);

    return castRecords;
  }
}
