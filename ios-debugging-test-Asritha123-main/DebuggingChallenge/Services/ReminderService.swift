/**
 # Task #2

 ## Task
 Fix the concurrency implementation in `DefaultReminderService` to correctly handle parallel reminder fetching using three different paradigms:

 1. Callback-Based (`fetchReminders`)
 2. Combine (`remindersPublisher`)
 3. Swift Concurrency (`fetchRemindersAsync`)

 Each implementation must:
 - Fetch three pages of reminders in parallel
 - Return a total of 12 reminders
 - Pass all associated tests in `DefaultReminderServiceTests`

 ## Success Criteria
 - All tests in `DefaultReminderServiceTests` pass successfully
 - Each method fetches exactly three pages concurrently
 - All methods return 12 unique reminders
 - Each implementation uses its designated concurrency paradigm
 - Each method has a unique implementation

 ## Important Notes
 - Some files are marked as "DO NOT MODIFY" - these must remain unchanged
 - In certain files, only specific sections are marked as protected with clear comments
 - Modifying any protected code (either entire files or marked sections) will result in automatic task failure
 - Work with the existing code structure; do not rewrite from scratch
 - Stay within each method's designated paradigm (Callbacks/Combine/Swift Concurrency)
 - Do not call other methods of the class within implementations
 */

import Combine
import Foundation

final class DefaultReminderService: ReminderService {
    private let dataSource: ReminderDataSource

    init(dataSource: ReminderDataSource) {
        self.dataSource = dataSource
    }

    func fetchReminders(completion: @escaping ([Reminder]) -> Void) {
        let group = DispatchGroup()
        let lock = NSLock()
        var buckets:[[Reminder]] = []
        
        
        for _ in 0 ..< 3 {
            group.enter()
            dataSource.fetchReminders { page in
                lock.lock()
                buckets.append(page)
                lock.unlock()
                group.leave()
            }
        }
        
        group.notify(queue: .main){
            completion(buckets.flatMap{$0})
        }
    }
            

       

    func remindersPublisher() -> AnyPublisher<[Reminder], Never> {
        let pages: [AnyPublisher<[Reminder], Never>] = (0..<3).map { _ in
            Future<[Reminder], Never> { promise in
                self.dataSource.fetchReminders { page in
                    promise(.success(page))
                }
            }
            .eraseToAnyPublisher()
        }
        return Publishers.MergeMany(pages)
            .collect(3)
            .map({$0.flatMap{$0}})
            .eraseToAnyPublisher()
    }

    func fetchRemindersAsync() async -> [Reminder] {
        async let a = dataSource.fetchReminders()
        async let b = dataSource.fetchReminders()
        async let c = dataSource.fetchReminders()
        let (r1, r2, r3) = await (a, b, c)
        return r1 + r2 + r3
    }
}
/*
 *****************************************************************************
 *                                                                           *
 *     >>>>>>>>>>>  DO NOT MODIFY ANYTHING FROM THIS POINT  <<<<<<<<<<<      *
 *                                                                           *
 *                YOU WILL AUTOMATICALLY FAIL IF YOU DO!                     *
 *                                                                           *
 *****************************************************************************
 */

protocol ReminderService: AnyObject {
    func fetchReminders(completion: @escaping ([Reminder]) -> Void)
    func remindersPublisher() -> AnyPublisher<[Reminder], Never>
    func fetchRemindersAsync() async -> [Reminder]
}

protocol ReminderDataSource: AnyObject {
    func fetchReminders(completion: @escaping ([Reminder]) -> Void)
    func fetchReminders() async -> [Reminder]
}
