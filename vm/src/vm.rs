use std::convert::TryFrom;

use crate::chunk::{Chunk, OpCode, Value};

const STACK_MAX: usize = 256;

pub enum InterpretResult {
    Ok,
    CompileError,
    RuntimeError,
}

pub struct Vm {
    chunk: Chunk,
    ip: usize,
    stack: Vec<Value>,
    debug: bool,
}

impl Vm {
    pub fn new(chunk: Chunk, debug: bool) -> Self {
        Vm {
            chunk,
            ip: 0,
            stack: vec![],
            debug,
        }
    }

    pub fn interpret(&mut self) -> InterpretResult {
        loop {
            let code = self.read_byte();
            let code = OpCode::try_from(code);
            if let Ok(op_code) = code {
                if self.debug {
                    self.chunk.disassemble_instruction(self.ip - 1);
                }

                match op_code {
                    OpCode::Return => break InterpretResult::Ok,
                    OpCode::Constant => {
                        let constant = self.read_constant();
                        self.push(constant);
                        break InterpretResult::Ok;
                    }
                }
            } else {
                break InterpretResult::RuntimeError;
            }
        }
    }

    fn read_byte(&mut self) -> u8 {
        let ip = self.advance_ip();
        let result = self.chunk.read_code(ip);
        *result
    }

    fn read_constant(&mut self) -> Value {
        let ip = self.advance_ip();
        let result = self.chunk.read_code(ip);
        let result = self.chunk.read_constant(*result as usize);
        *result
    }

    fn advance_ip(&mut self) -> usize {
        let result = self.ip;
        self.ip = self.ip + 1;
        result
    }

    fn push(&mut self, value: Value) {
        self.stack.push(value);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn vm() {
        let mut chunk = Chunk::new("test chunk");
        let constant = chunk.add_constant(1.2);
        chunk.write(OpCode::Constant as u8, 1);
        chunk.write(constant as u8, 1);
        chunk.write(OpCode::Return as u8, 1);

        let mut vm = Vm::new(chunk, true);
        vm.interpret();
    }
}
