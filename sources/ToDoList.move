use std::bcs;
use std::signer;
use aptos_framework::object;
use aptos_framework::object::Object;

struct Todo has store, drop, copy {
    content: String,
    completed: bool,
}
// Each todo list is stored as a resource
struct TodoList has key {
    owner: address,
    todos: vector<Todo>,
}
struct UserTodoListCounter has key {
    counter: u64,
}

public entry fun create_todo_list(sender: &signer) acquires UserTodoListCounter {
    let sender_address = signer::address_of(sender);
    let counter = if (exists<UserTodoListCounter>(sender_address)) {
        let counter = borrow_global<UserTodoListCounter>(sender_address);
        counter.counter
    } else {
        let counter = UserTodoListCounter { counter: 0 };
        // store the UserTodoListCounter resource directly under the sender
        move_to(sender, counter);
        0
    };
    // create a new object to hold the todo list, use the counter as seed
    let obj_holds_todo_list = object::create_named_object(sender, bcs::to_bytes(&counter));
    let obj_signer = object::generate_signer(&obj_holds_todo_list);
    let todo_list = TodoList {
        owner: sender_address,
        todos: vector::empty(),
    };
    // store the TodoList resource under the newly created object
    move_to(&obj_signer, todo_list);
    // increment the counter
    let counter = borrow_global_mut<UserTodoListCounter>(sender_address);
    counter.counter = counter.counter + 1;
}

#[view]
public fun get_todo_list(sender: address, todo_list_idx: u64): (address, u64) acquires TodoList {
    let todo_list_obj_addr = object::create_object_address(&sender, bcs::to_bytes(&todo_list_idx));
    let todo_list = borrow_global<TodoList>(todo_list_obj_addr);
    (todo_list.owner, vector::length(&todo_list.todos))
}
