// Function to calculate a simple hash code for a string
function hashCode(str: string): number {
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    const char = str.charCodeAt(i);
    // eslint-disable-next-line no-bitwise
    hash = (hash << 5) - hash + char;
  }
  return hash;
}

// Function to create a string hash from a TypeScript object
export function objectHash(obj: Record<string, any>): string {
  if (!obj) {
    return '';
  }
  // Convert the object to a JSON string
  const jsonString = JSON.stringify(obj);

  // Calculate the hash code of the JSON string
  const hash = hashCode(jsonString);

  // Convert the hash code to a string (optional)
  return String(hash);
}
