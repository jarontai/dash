use std::convert::TryFrom;

type Value = f64;

#[repr(u8)]
enum OpCode {
    Constant = 0,
    Return,
}

impl TryFrom<u8> for OpCode {
    type Error = &'static str;

    fn try_from(value: u8) -> Result<Self, Self::Error> {
        match value {
            v if v == OpCode::Constant as u8 => Ok(OpCode::Constant),
            v if v == OpCode::Return as u8 => Ok(OpCode::Return),
            _ => Err("Unknown opcode"),
        }
    }
}

struct Chunk {
    name: &'static str,
    codes: Vec<u8>,
    constants: Vec<Value>,
}

impl Chunk {
    pub fn new(name: &'static str) -> Self {
        Chunk {
            name,
            codes: vec![],
            constants: vec![],
        }
    }

    pub fn init(name: &'static str, codes: Vec<u8>) -> Self {
        Chunk {
            name,
            codes,
            constants: vec![],
        }
    }

    pub fn write(&mut self, code: u8) {
        self.codes.push(code);
    }

    pub fn add_constant(&mut self, val: Value) -> usize {
        self.constants.push(val);
        self.constants.len() - 1
    }

    fn disassemble(&self) {
        println!("== {} ==", self.name);

        let mut offset = 0;
        while offset < self.codes.len() {
            offset = self.disassemble_instruction(offset);
        }
    }

    fn disassemble_instruction(&self, offset: usize) -> usize {
        print!("{:04} ", offset);

        let raw_code = self.codes[offset];
        match OpCode::try_from(raw_code) {
            Ok(code) => match code {
                OpCode::Constant => self.constant_instruction("OP_CONSTANT", offset),
                OpCode::Return => self.simple_instruction("OP_RETURN", offset),
            },
            Err(msg) => {
                println!("{} {}", msg, raw_code);
                offset + 1
            }
        }
    }

    fn simple_instruction(&self, name: &str, offset: usize) -> usize {
        println!("{}", name);
        offset + 1
    }

    fn constant_instruction(&self, name: &str, offset: usize) -> usize {
        let index = self.codes[offset + 1];
        print!("{} {} ", name, index);
        println!("{}", self.constants[index as usize]);
        offset + 2
    }
}

mod tests {
    use super::*;

    #[test]
    fn chunk() {
        let mut chunk = Chunk::new("test chunk");
        let constant = chunk.add_constant(1.2);
        chunk.write(OpCode::Constant as u8);
        chunk.write(constant as u8);
        chunk.write(OpCode::Return as u8);
        chunk.disassemble();
    }
}
