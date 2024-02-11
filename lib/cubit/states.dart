abstract class ToDoAppStates{}

class InitialState extends ToDoAppStates{}

class SwapBottomNavBar extends ToDoAppStates{}
class SwapBottomSheetState extends ToDoAppStates{}

/// Database
class CreateDatabaseState extends ToDoAppStates{}

class InsertToDatabaseState extends ToDoAppStates{}

class GetRecordsFromDatabaseState extends ToDoAppStates{}

class UpdateInToDatabaseState extends ToDoAppStates{}

class DeleteFromDatabaseState extends ToDoAppStates{}

class GetRecordsLoadingState extends ToDoAppStates{}
