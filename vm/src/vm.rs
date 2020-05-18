use std::convert::TryFrom;

use crate::chunk::{Chunk, OpCode, Value};

pub enum InterpretResult {
    Ok,
    CompileError,
    RuntimeError,
}

pub struct Vm {
    chunk: Chunk,
    ip: usize,
}

impl Vm {
    pub fn new(chunk: Chunk) -> Self {
        Vm { chunk, ip: 0 }
    }

    pub fn interpret(&mut self) -> InterpretResult {
        loop {
            let code = self.read_byte();
            let code = OpCode::try_from(code);
            if let Ok(op_code) = code {
                match op_code {
                    OpCode::Return => break InterpretResult::Ok,
                    OpCode::Constant => {
                        let constant = self.read_constant();
                        println!("{}", constant);
                        break InterpretResult::Ok;
                    }
                }
            } else {
                break InterpretResult::RuntimeError;
            }
        }
    }

    fn read_byte(&mut self) -> &u8 {
        let ip = self.advance_ip();
        let result = self.chunk.read_code(ip);
        result
    }

    fn read_constant(&mut self) -> &Value {
        let ip = self.advance_ip();
        let result = self.chunk.read_code(ip);
        self.chunk.read_constant(*result as usize)
    }

    fn advance_ip(&mut self) -> usize {
        let result = self.ip;
        self.ip = self.ip + 1;
        result
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn vm() {}
}
