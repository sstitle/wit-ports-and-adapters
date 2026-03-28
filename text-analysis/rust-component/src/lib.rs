#![no_std]
extern crate alloc;

use alloc::collections::BTreeMap;
use alloc::string::{String, ToString};
use alloc::vec::Vec;

#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;

wit_bindgen::generate!({
    world: "text-analyzer",
    path: "../wit",
});

use exports::example::text_analysis::analyzer::*;

struct TextAnalyzer;

impl Guest for TextAnalyzer {
    fn analyze(text: String, top_n: u32) -> Result<AnalysisResult, String> {
        if text.is_empty() {
            return Err("Input text cannot be empty".to_string());
        }

        let mut counts: BTreeMap<String, u32> = BTreeMap::new();

        for word in text.split_whitespace() {
            let clean: String = word
                .chars()
                .filter(|c| c.is_alphabetic())
                .map(|c| c.to_lowercase().next().unwrap())
                .collect();
            if !clean.is_empty() {
                *counts.entry(clean).or_insert(0) += 1;
            }
        }

        let total_words: u32 = counts.values().sum();
        let unique_words = counts.len() as u32;

        let mut sorted: Vec<_> = counts.into_iter().collect();
        sorted.sort_by(|a, b| b.1.cmp(&a.1).then(a.0.cmp(&b.0)));

        let top_words = sorted
            .into_iter()
            .take(top_n as usize)
            .map(|(word, count)| WordStats { word, count })
            .collect();

        Ok(AnalysisResult {
            total_words,
            unique_words,
            top_words,
        })
    }
}

export!(TextAnalyzer);

#[cfg(not(test))]
#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    core::arch::wasm32::unreachable()
}
