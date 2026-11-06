use std::env;
use std::fs;
use std::sync::mpsc;
use std::thread;

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 3 {
        eprintln!("usage: {} <pattern> <file1> [file2 ...]", args[0]);
        std::process::exit(1);
    }

    let pattern = args[1].clone();
    let files: Vec<String> = args[2..].to_vec();

    let (tx, rx) = mpsc::channel::<(String, usize, String)>();

    let mut handles = vec![];
    for file in files {
        let tx = tx.clone();
        let pattern = pattern.clone();
        let handle = thread::spawn(move || match fs::read_to_string(&file) {
            Ok(content) => {
                for (idx, line) in content.lines().enumerate() {
                    if line.contains(&pattern) {
                        if tx.send((file.clone(), idx + 1, line.to_string())).is_err() {
                            break;
                        }
                    }
                }
            }
            Err(e) => eprintln!("error reading {}: {}", file, e),
        });
        handles.push(handle);
    }
    drop(tx);

    let mut matches: Vec<(String, usize, String)> = rx.iter().collect();
    matches.sort_by(|a, b| a.0.cmp(&b.0).then(a.1.cmp(&b.1)));

    for (file, line, text) in &matches {
        println!("{}:{}: {}", file, line, text);
    }
    println!("total matches: {}", matches.len());

    for h in handles {
        h.join().expect("thread panicked");
    }
}